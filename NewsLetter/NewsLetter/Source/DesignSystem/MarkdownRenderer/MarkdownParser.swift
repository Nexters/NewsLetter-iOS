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
    // Callout 문법을 내부 마커로 변환: "> [!tip]" → "%%CALLOUT:tip%%"
    private func preprocess(_ text: String) -> String {
        var result = text
        let calloutPattern = #"^>\s*\[!(tip|info|warning|danger|note|important)\]\s*\n?"#
        let regex = try? NSRegularExpression(pattern: calloutPattern,
                                             options: [.anchorsMatchLines, .caseInsensitive])
        let range = NSRange(result.startIndex..., in: result)
        guard let matches = regex?.matches(in: result, range: range) else { return result }

        // 뒤에서부터 치환 (인덱스 밀림 방지)
        for match in matches.reversed() {
            guard let swiftRange = Range(match.range, in: result),
                  let typeRange = Range(match.range(at: 1), in: result) else { continue }
            let type = String(result[typeRange]).lowercased()
            result.replaceSubrange(swiftRange, with: "%%CALLOUT:\(type)%%\n")
        }
        return result
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

            // Callout 마커
            if trimmed.hasPrefix("%%CALLOUT:") {
                let typeStr = trimmed
                    .replacingOccurrences(of: "%%CALLOUT:", with: "")
                    .replacingOccurrences(of: "%%", with: "")
                    .lowercased()
                let calloutType = CalloutType(rawValue: typeStr) ?? .note
                var bodyLines: [String] = []
                i += 1
                while i < lines.count {
                    let next = lines[i]
                    if next.hasPrefix(">") {
                        bodyLines.append(String(next.dropFirst()).trimmingCharacters(in: .whitespaces))
                        i += 1
                    } else if next.trimmingCharacters(in: .whitespaces).isEmpty {
                        break
                    } else {
                        break
                    }
                }
                let children = parseBlocks(lines: bodyLines)
                nodes.append(.callout(type: calloutType, children: children))
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
            if let rest = parseOrderedItem(trimmed) {
                var items: [[MarkdownNode]] = []
                var j = i
                while j < lines.count {
                    let t = lines[j].trimmingCharacters(in: .whitespaces)
                    if let r = parseOrderedItem(t) {
                        items.append(parseInline(r))
                        j += 1
                    } else if t.isEmpty {
                        break
                    } else {
                        break
                    }
                }
                i = j
                nodes.append(.orderedList(items: items))
                continue
            }

            // Paragraph: 연속된 비-공백 줄 묶기
            var paraLines: [String] = []
            while i < lines.count {
                let t = lines[i].trimmingCharacters(in: .whitespaces)
                if t.isEmpty { break }
                if t.hasPrefix("#") || t.hasPrefix("```") || t.hasPrefix("|") { break }
                if t == "---" || t == "***" { break }
                paraLines.append(lines[i])
                i += 1
            }
            if !paraLines.isEmpty {
                let combined = paraLines.joined(separator: " ")
                nodes.append(.paragraph(children: parseInline(combined)))
            }
        }

        return nodes
    }

    // MARK: - Inline Parsing

    func parseInline(_ text: String) -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []
        var remaining = text[text.startIndex...]

        while !remaining.isEmpty {
            // Bold+Italic: ***text***
            if let range = remaining.range(of: "***"),
               let endRange = remaining[range.upperBound...].range(of: "***") {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { nodes.append(.text(before)) }
                let inner = String(remaining[range.upperBound..<endRange.lowerBound])
                nodes.append(.boldItalic(children: parseInline(inner)))
                remaining = remaining[endRange.upperBound...]
                continue
            }
            // Bold: **text**
            if let range = remaining.range(of: "**"),
               let endRange = remaining[range.upperBound...].range(of: "**") {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { nodes.append(.text(before)) }
                let inner = String(remaining[range.upperBound..<endRange.lowerBound])
                nodes.append(.bold(children: parseInline(inner)))
                remaining = remaining[endRange.upperBound...]
                continue
            }
            // Italic: *text*
            if let range = remaining.range(of: "*"),
               let endRange = remaining[range.upperBound...].range(of: "*") {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { nodes.append(.text(before)) }
                let inner = String(remaining[range.upperBound..<endRange.lowerBound])
                nodes.append(.italic(children: parseInline(inner)))
                remaining = remaining[endRange.upperBound...]
                continue
            }
            // Inline code: `code`
            if let range = remaining.range(of: "`"),
               let endRange = remaining[range.upperBound...].range(of: "`") {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { nodes.append(.text(before)) }
                let inner = String(remaining[range.upperBound..<endRange.lowerBound])
                nodes.append(.code(inner))
                remaining = remaining[endRange.upperBound...]
                continue
            }
            // 남은 텍스트 전체
            nodes.append(.text(String(remaining)))
            break
        }

        return nodes
    }

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

    private func parseOrderedItem(_ line: String) -> String? {
        guard let dotRange = line.range(of: ". "),
              let numStr = line.range(of: ".")
                .map({ String(line[line.startIndex..<$0.lowerBound]) }),
              Int(numStr) != nil else { return nil }
        return String(line[dotRange.upperBound...])
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
