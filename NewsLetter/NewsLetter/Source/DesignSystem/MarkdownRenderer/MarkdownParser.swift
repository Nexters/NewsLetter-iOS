import Foundation

// MARK: - Markdown Parser

struct MarkdownParser {

    // MARK: Public

    func parse(_ raw: String) -> [MarkdownNode] {
        let preprocessed = preprocess(raw)
        let lines = preprocessed.components(separatedBy: "\n")
        return parseBlocks(lines: lines)
    }

    // MARK: - Preprocessing

    /// 서버 응답에 이스케이프된 채로 내려오는 개행 문자("\n" 두 글자)를 실제 개행으로 되돌린다
    private func preprocess(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\n", with: "\n")
    }

    // MARK: - Block Parsing

    private func parseBlocks(lines: [String]) -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // 빈 줄 스킵
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                i += 1
                continue
            }

            // 코드 블록 (```)
            if line.hasPrefix("```") {
                let lang = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                // 펜스 안쪽의 앞뒤 빈 줄은 렌더링 시 여백만 늘리므로 제거한다
                while let first = codeLines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
                    codeLines.removeFirst()
                }
                while let last = codeLines.last, last.trimmingCharacters(in: .whitespaces).isEmpty {
                    codeLines.removeLast()
                }
                nodes.append(.codeBlock(language: lang.isEmpty ? nil : lang,
                                        code: codeLines.joined(separator: "\n")))
                i += 1
                continue
            }

            // Heading
            if let (level, rest) = parseHeadingLine(line) {
                nodes.append(.heading(level: level, children: parseInline(rest)))
                i += 1
                continue
            }

            // Horizontal rule
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                nodes.append(.horizontalRule)
                i += 1
                continue
            }

            // Table
            if trimmed.hasPrefix("|") && trimmed.hasSuffix("|") {
                var tableLines: [String] = [line]
                i += 1
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("|") {
                    tableLines.append(lines[i])
                    i += 1
                }
                if let table = parseTable(tableLines) {
                    nodes.append(table)
                }
                continue
            }

            // Blockquote
            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                    quoteLines.append(String(lines[i].dropFirst()).trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                nodes.append(.blockquote(children: parseBlocks(lines: quoteLines)))
                continue
            }

            // Bullet list
            if isBulletItem(trimmed) {
                var items: [[MarkdownNode]] = []
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    if isBulletItem(t) {
                        let content = String(t.dropFirst(2))
                        items.append(parseInline(content))
                        i += 1
                    } else if t.isEmpty {
                        break
                    } else {
                        break
                    }
                }
                nodes.append(.bulletList(items: items))
                continue
            }

            // Ordered list
            if let first = parseOrderedItem(trimmed) {
                var items: [OrderedListItem] = []
                var itemNumber = first.number
                var itemLines: [String] = [first.content]
                i += 1

                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)

                    if let item = parseOrderedItem(t) {
                        items.append(OrderedListItem(number: itemNumber, children: inlineLines(itemLines)))
                        itemNumber = item.number
                        itemLines = [item.content]
                        i += 1
                    } else if t.isEmpty {
                        // 빈 줄 뒤에 다음 번호가 이어지면 같은 목록으로 본다
                        var j = i
                        while j < lines.count && lines[j].trimmingCharacters(in: .whitespaces).isEmpty {
                            j += 1
                        }
                        guard j < lines.count,
                              parseOrderedItem(lines[j].trimmingCharacters(in: .whitespaces)) != nil else { break }
                        i = j
                    } else if isBlockBoundary(t) {
                        break
                    } else {
                        // 번호 없이 이어지는 줄은 현재 항목의 본문으로 붙인다
                        itemLines.append(lines[i])
                        i += 1
                    }
                }

                items.append(OrderedListItem(number: itemNumber, children: inlineLines(itemLines)))
                nodes.append(.orderedList(items: items))
                continue
            }

            // Paragraph: 연속된 비-공백 줄 묶기
            //
            // 첫 줄은 무조건 소비한다. 앞선 어떤 블록 분기도 처리하지 못했지만
            // isBlockBoundary는 true인 줄("#800 — ..."처럼 heading이 아닌 # 시작 줄,
            // 닫는 파이프가 없는 표 줄 등)이 여기 도달하는데,
            // 경계로 보고 바로 끊으면 i가 전진하지 않아 무한 루프에 빠진다.
            var paraLines: [String] = [lines[i]]
            i += 1
            while i < lines.count {
                let t = lines[i].trimmingCharacters(in: .whitespaces)
                if t.isEmpty { break }
                if isBlockBoundary(t) { break }
                paraLines.append(lines[i])
                i += 1
            }
            nodes.append(.paragraph(children: inlineLines(paraLines)))
        }

        return nodes
    }

    // MARK: - Inline Parsing

    private func parseInline(_ text: String) -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []
        var remaining = text

        while !remaining.isEmpty {
            guard let match = firstInlineMatch(in: remaining) else {
                nodes.append(.text(remaining))
                break
            }
            let before = String(remaining[remaining.startIndex..<match.range.lowerBound])
            if !before.isEmpty { nodes.append(.text(before)) }
            nodes.append(match.node)
            remaining = String(remaining[match.range.upperBound...])
        }

        return nodes
    }

    /// 가장 앞에 등장하는 인라인 문법 하나를 찾는다 (같은 위치면 선언 순서가 우선)
    private func firstInlineMatch(in text: String) -> InlineMatch? {
        let candidates: [() -> InlineMatch?] = [
            { self.delimitedMatch(in: text, marker: "***") { .boldItalic(children: self.parseInline($0)) } },
            { self.delimitedMatch(in: text, marker: "**") { .bold(children: self.parseInline($0)) } },
            { self.delimitedMatch(in: text, marker: "*") { .italic(children: self.parseInline($0)) } },
            { self.delimitedMatch(in: text, marker: "`") { .code($0) } },
            { self.linkMatch(in: text) },
            { self.autoLinkMatch(in: text) }
        ]

        var best: InlineMatch?
        for candidate in candidates {
            guard let match = candidate() else { continue }
            if best == nil || match.range.lowerBound < best!.range.lowerBound {
                best = match
            }
        }
        return best
    }

    private func delimitedMatch(in text: String,
                                marker: String,
                                make: (String) -> MarkdownNode) -> InlineMatch? {
        guard let open = text.range(of: marker),
              let close = text[open.upperBound...].range(of: marker) else { return nil }
        let inner = String(text[open.upperBound..<close.lowerBound])
        return InlineMatch(range: open.lowerBound..<close.upperBound, node: make(inner))
    }

    /// [표시 문구](https://...)
    private func linkMatch(in text: String) -> InlineMatch? {
        guard let match = Self.linkRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let full = Range(match.range, in: text),
              let labelRange = Range(match.range(at: 1), in: text),
              let urlRange = Range(match.range(at: 2), in: text) else { return nil }
        let label = String(text[labelRange])
        let url = String(text[urlRange])
        return InlineMatch(range: full,
                           node: .link(children: label.isEmpty ? [.text(url)] : parseInline(label), url: url))
    }

    /// 마크다운 링크 문법 없이 노출된 URL
    private func autoLinkMatch(in text: String) -> InlineMatch? {
        guard let match = Self.autoLinkRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              var range = Range(match.range, in: text) else { return nil }

        // 문장 끝 구두점은 링크에서 제외한다
        while let last = text[range].last, ".,)]}>\"'".contains(last) {
            range = range.lowerBound..<text.index(before: range.upperBound)
        }
        guard !text[range].isEmpty else { return nil }

        let url = String(text[range])
        return InlineMatch(range: range, node: .link(children: [.text(Self.linkLabel(for: url))], url: url))
    }

    /// 긴 URL을 그대로 노출하지 않도록 도메인만 보여준다
    private static func linkLabel(for url: String) -> String {
        guard let host = URL(string: url)?.host, !host.isEmpty else { return url }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private struct InlineMatch {
        let range: Range<String.Index>
        let node: MarkdownNode
    }

    private static let linkRegex = try! NSRegularExpression(pattern: #"\[([^\]]*)\]\(([^)\s]+)\)"#)
    private static let autoLinkRegex = try! NSRegularExpression(pattern: #"https?://[^\s<>\[\]()]+"#)

    // MARK: - Helpers

    private func parseHeadingLine(_ line: String) -> (Int, String)? {
        var level = 0
        var rest = line[line.startIndex...]
        while rest.first == "#" {
            level += 1
            rest = rest.dropFirst()
        }
        guard level > 0 && level <= 6,
              rest.first == " " else { return nil }
        return (level, String(rest.dropFirst()))
    }

    private func isBulletItem(_ line: String) -> Bool {
        line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ")
    }

    private func parseOrderedItem(_ line: String) -> (number: Int, content: String)? {
        guard let dotIndex = line.firstIndex(of: "."), dotIndex != line.startIndex,
              let number = Int(line[line.startIndex..<dotIndex]) else { return nil }
        let afterDot = line.index(after: dotIndex)
        guard afterDot < line.endIndex, line[afterDot] == " " else { return nil }
        return (number, String(line[line.index(after: afterDot)...]))
    }

    /// 다른 블록 문법이 시작되는 줄인지 판단한다 (문단 / 목록 항목이 여기서 끊긴다)
    private func isBlockBoundary(_ trimmed: String) -> Bool {
        if trimmed.hasPrefix("#") || trimmed.hasPrefix("```") || trimmed.hasPrefix("|") { return true }
        if trimmed.hasPrefix(">") { return true }
        if trimmed == "---" || trimmed == "***" || trimmed == "___" { return true }
        return isBulletItem(trimmed)
    }

    /// 여러 줄을 하나의 인라인 묶음으로 만든다. 줄 사이 개행은 그대로 유지한다.
    private func inlineLines(_ lines: [String]) -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []
        for (index, line) in lines.enumerated() {
            if index > 0 { nodes.append(.lineBreak) }
            nodes.append(contentsOf: parseInline(line.trimmingCharacters(in: .whitespaces)))
        }
        return nodes
    }

    private func parseTable(_ lines: [String]) -> MarkdownNode? {
        guard lines.count >= 2 else { return nil }

        func cells(_ line: String) -> [String] {
            line.split(separator: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty && !$0.allSatisfy({ $0 == "-" || $0 == ":" }) }
        }

        let header = cells(lines[0])
        guard !header.isEmpty else { return nil }
        let rows = lines.dropFirst(2).map { cells($0) }.filter { !$0.isEmpty }
        return .table(header: header, rows: rows)
    }
}
