import SwiftUI

// MARK: - Block Node View

struct BlockNodeView: View {
    let node: MarkdownNode
    var pointColor: Color = SemanticColor().text_strong
    var isDarkTheme: Bool = false

    var body: some View {
        switch node {
        case .heading(let level, let children):
            HeadingView(level: level, children: children, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .paragraph(let children):
            InlineText(children: children, pointColor: pointColor, isDarkTheme: isDarkTheme)
                .font(.body15_regular)
                .foregroundStyle(isDarkTheme ? ColorPalette.gray200 : .semanticColor.text_secondary)
                .lineSpacing(7)

        case .codeBlock(let lang, let code):
            CodeBlockView(language: lang, code: code, isDarkTheme: isDarkTheme)

        case .blockquote(let children):
            BlockquoteView(children: children, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .bulletList(let items):
            BulletListView(items: items, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .orderedList(let items):
            OrderedListView(items: items, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .horizontalRule:
            Divider()
                .background(isDarkTheme ? ColorPalette.gray700 : .semanticColor.divider_1pxStrong)
                .padding(.vertical, 4)

        case .table(let header, let rows):
            TableView(header: header, rows: rows, isDarkTheme: isDarkTheme)

        default:
            EmptyView()
        }
    }
}

// MARK: - Heading

private struct HeadingView: View {
    let level: Int
    let children: [MarkdownNode]
    let pointColor: Color
    var isDarkTheme: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InlineText(children: children, pointColor: pointColor, isDarkTheme: isDarkTheme)
                .font(fontStyle)
                .foregroundStyle(level <= 3 ? pointColor : (isDarkTheme ? ColorPalette.white : .semanticColor.text_primary))

            if level <= 2 {
                Divider()
                    .background(isDarkTheme ? ColorPalette.gray700 : .semanticColor.divider_1pxStrong)
            }
        }
        .padding(.top, topPadding)
    }

    private var fontStyle: FontStyle {
        switch level {
        case 1: return .head22_bold
        case 2: return .head20_semiBold
        case 3: return .body16_semiBold
        default: return .body15_medium
        }
    }

    // 중간 제목(###)은 앞 문단과 구분되도록 위쪽 여백을 더 준다
    private var topPadding: CGFloat {
        switch level {
        case 1: return 4
        case 3: return 20
        default: return 0
        }
    }
}

// MARK: - Blockquote

private struct BlockquoteView: View {
    let children: [MarkdownNode]
    var pointColor: Color = SemanticColor().text_strong
    var isDarkTheme: Bool = false

    // 어두운 배경에서는 파란 계열을 유지하되 명도만 뒤집어 인용문 정체성을 지킨다
    private var backgroundColor: Color { isDarkTheme ? ColorPalette.pointBlue900 : ColorPalette.pointBlue50 }
    private var borderColor: Color { isDarkTheme ? ColorPalette.pointBlue800 : ColorPalette.pointBlue150 }
    private var textColor: Color { isDarkTheme ? ColorPalette.gray200 : SemanticColor().text_secondary }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(ColorPalette.pointBlue400)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    BlockNodeView(node: child, pointColor: pointColor, isDarkTheme: isDarkTheme)
                        .font(.body13_regular)
                        .foregroundStyle(textColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 0.5)
        )
    }
}

// MARK: - Code Block

private struct CodeBlockView: View {
    let language: String?
    let code: String
    var isDarkTheme: Bool = false

    private var backgroundColor: Color { isDarkTheme ? ColorPalette.gray800 : ColorPalette.gray30 }
    private var borderColor: Color { isDarkTheme ? ColorPalette.gray700 : SemanticColor().border_primary }
    private var codeColor: Color { isDarkTheme ? ColorPalette.gray100 : SemanticColor().text_primary }
    private var languageTagColor: Color { isDarkTheme ? ColorPalette.gray300 : SemanticColor().text_tertiary }
    private var languageTagBackgroundColor: Color { isDarkTheme ? ColorPalette.gray700 : ColorPalette.gray100 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 언어 태그 + 구분선
            if let lang = language, !lang.isEmpty {
                HStack(spacing: 0) {
                    Text(lang)
                        .font(.caption11_semiBold)
                        .foregroundStyle(languageTagColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(languageTagBackgroundColor)
                        )

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)

                Divider()
                    .background(borderColor)
            }

            // 좁은 모바일 화면에서는 가로 스크롤 대신 줄바꿈으로 코드 전체가 보이게 한다
            Text(code)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(codeColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .textSelection(.enabled)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Lists

private struct BulletListView: View {
    let items: [[MarkdownNode]]
    let pointColor: Color
    var isDarkTheme: Bool = false

    private var boldColor: Color { isDarkTheme ? ColorPalette.white : SemanticColor().text_primary }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(pointColor)
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)

                    InlineText(children: item, pointColor: boldColor, isDarkTheme: isDarkTheme)
                        .font(.body15_regular)
                        .foregroundStyle(isDarkTheme ? ColorPalette.gray200 : .semanticColor.text_secondary)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct OrderedListView: View {
    let items: [OrderedListItem]
    let pointColor: Color
    var isDarkTheme: Bool = false

    private var boldColor: Color { isDarkTheme ? ColorPalette.white : SemanticColor().text_primary }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    // 두 자리 번호도 잘리지 않도록 캡슐 배경을 쓴다
                    Text("\(item.number)")
                        .font(.caption12_semiBold)
                        .foregroundStyle(pointColor)
                        .padding(.horizontal, 5)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(
                            Capsule()
                                .fill(pointColor.opacity(0.12))
                        )
                        .padding(.top, 1)

                    InlineText(children: item.children, pointColor: boldColor, isDarkTheme: isDarkTheme)
                        .font(.body15_regular)
                        .foregroundStyle(isDarkTheme ? ColorPalette.gray200 : .semanticColor.text_secondary)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - Table

private struct TableView: View {
    let header: [String]
    let rows: [[String]]
    var isDarkTheme: Bool = false

    private var headerBackgroundColor: Color { isDarkTheme ? ColorPalette.gray800 : ColorPalette.gray50 }
    private var headerTextColor: Color { isDarkTheme ? ColorPalette.gray300 : SemanticColor().text_tertiary }
    private var cellTextColor: Color { isDarkTheme ? ColorPalette.gray200 : SemanticColor().text_secondary }
    private var borderColor: Color { isDarkTheme ? ColorPalette.gray700 : SemanticColor().border_primary }
    private var dividerColor: Color { isDarkTheme ? ColorPalette.gray700 : SemanticColor().divider_1pxStrong }

    /// 홀수 행에만 옅은 음영을 주어 행을 구분한다
    private func rowBackgroundColor(at index: Int) -> Color {
        if isDarkTheme {
            return index % 2 == 1 ? ColorPalette.gray800 : ColorPalette.gray900
        }
        return index % 2 == 1 ? ColorPalette.gray30 : ColorPalette.white
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 0) {
                ForEach(Array(header.enumerated()), id: \.offset) { idx, col in
                    Text(col)
                        .font(.body13_semiBold)
                        .foregroundStyle(headerTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if idx < header.count - 1 {
                        Divider()
                            .background(dividerColor)
                    }
                }
            }
            .background(headerBackgroundColor)

            Divider()
                .background(borderColor)

            // 바디 행
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIdx, cell in
                        Text(cell)
                            .font(.body13_regular)
                            .foregroundStyle(cellTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if colIdx < row.count - 1 {
                            Divider()
                                .background(dividerColor)
                        }
                    }
                }
                .background(rowBackgroundColor(at: rowIdx))

                if rowIdx < rows.count - 1 {
                    Divider()
                        .background(dividerColor)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Inline Text

private struct InlineText: View {
    let children: [MarkdownNode]
    var pointColor: Color = SemanticColor().text_strong
    var isDarkTheme: Bool = false

    var body: some View {
        Text(attributedString)
            .tint(pointColor)   // 링크에는 SwiftUI의 tint가 적용된다
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedString: AttributedString {
        children.reduce(AttributedString()) {
            $0 + $1.attributedString(pointColor: pointColor, isDarkTheme: isDarkTheme)
        }
    }
}

private extension MarkdownNode {
    func attributedString(pointColor: Color, isDarkTheme: Bool) -> AttributedString {
        switch self {
        case .text(let str):
            return AttributedString(str)

        case .bold(let children):
            var result = children.reduce(AttributedString()) {
                $0 + $1.attributedString(pointColor: pointColor, isDarkTheme: isDarkTheme)
            }
            result.font = UIFont(name: "Pretendard-SemiBold", size: 14)
            result.foregroundColor = UIColor(pointColor)
            return result

        case .italic(let children):
            var result = children.reduce(AttributedString()) {
                $0 + $1.attributedString(pointColor: pointColor, isDarkTheme: isDarkTheme)
            }
            result.font = UIFont(name: "Pretendard-RegularItalic", size: 14)
                ?? .italicSystemFont(ofSize: 14)
            return result

        case .boldItalic(let children):
            var result = children.reduce(AttributedString()) {
                $0 + $1.attributedString(pointColor: pointColor, isDarkTheme: isDarkTheme)
            }
            result.font = UIFont(name: "Pretendard-SemiBold", size: 14)
            result.foregroundColor = UIColor(pointColor)
            return result

        case .code(let str):
            // 어두운 배경에서는 밝은 회색 배경 대신 한 단계 밝은 어두운 배경 + 밝은 글자로 대비를 준다
            var result = AttributedString(str)
            result.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
            result.backgroundColor = UIColor(isDarkTheme ? ColorPalette.gray800 : ColorPalette.gray100)
            result.foregroundColor = UIColor(isDarkTheme ? ColorPalette.gray100 : SemanticColor().text_primary)
            return result

        case .link(let children, let url):
            var result = children.reduce(AttributedString()) {
                $0 + $1.attributedString(pointColor: pointColor, isDarkTheme: isDarkTheme)
            }
            if let linkURL = URL(string: url) { result.link = linkURL }
            result.foregroundColor = UIColor(pointColor)
            result.underlineStyle = .single
            return result

        case .lineBreak:
            return AttributedString("\n")

        default:
            return AttributedString()
        }
    }
}
