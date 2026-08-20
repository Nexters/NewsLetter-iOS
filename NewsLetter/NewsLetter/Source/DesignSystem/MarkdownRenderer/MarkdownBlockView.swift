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
            InlineText(children: children, pointColor: pointColor)
                .font(.body15_regular)
                .foregroundStyle(isDarkTheme ? ColorPalette.gray200 : .semanticColor.text_secondary)
                .lineSpacing(7)

        case .codeBlock(let lang, let code):
            CodeBlockView(language: lang, code: code)

        case .blockquote(let children):
            BlockquoteView(children: children)

        case .bulletList(let items):
            BulletListView(items: items, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .orderedList(let items):
            OrderedListView(items: items, pointColor: pointColor, isDarkTheme: isDarkTheme)

        case .horizontalRule:
            Divider()
                .background(isDarkTheme ? ColorPalette.gray700 : .semanticColor.divider_1pxStrong)
                .padding(.vertical, 4)

        case .table(let header, let rows):
            TableView(header: header, rows: rows)

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
            InlineText(children: children, pointColor: pointColor)
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

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(ColorPalette.pointBlue400)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    BlockNodeView(node: child)
                        .font(.body13_regular)
                        .foregroundStyle(.semanticColor.text_secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ColorPalette.pointBlue50)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorPalette.pointBlue150, lineWidth: 0.5)
        )
    }
}

// MARK: - Code Block

private struct CodeBlockView: View {
    let language: String?
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 언어 태그 + 구분선
            if let lang = language, !lang.isEmpty {
                HStack(spacing: 0) {
                    Text(lang)
                        .font(.caption11_semiBold)
                        .foregroundStyle(.semanticColor.text_tertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ColorPalette.gray100)
                        )

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)

                Divider()
                    .background(.semanticColor.divider_1pxStrong)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.semanticColor.text_primary)
                    .padding(14)
                    .textSelection(.enabled)
            }
        }
        .background(ColorPalette.gray30)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.semanticColor.border_primary, lineWidth: 1)
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

                    InlineText(children: item, pointColor: boldColor)
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

                    InlineText(children: item.children, pointColor: boldColor)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 0) {
                ForEach(Array(header.enumerated()), id: \.offset) { idx, col in
                    Text(col)
                        .font(.body13_semiBold)
                        .foregroundStyle(.semanticColor.text_tertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if idx < header.count - 1 {
                        Divider()
                            .background(.semanticColor.divider_1pxStrong)
                    }
                }
            }
            .background(ColorPalette.gray50)

            Divider()
                .background(.semanticColor.border_primary)

            // 바디 행
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIdx, cell in
                        Text(cell)
                            .font(.body13_regular)
                            .foregroundStyle(.semanticColor.text_secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if colIdx < row.count - 1 {
                            Divider()
                                .background(.semanticColor.divider_1pxStrong)
                        }
                    }
                }
                .background(rowIdx % 2 == 1 ? ColorPalette.gray30 : ColorPalette.white)

                if rowIdx < rows.count - 1 {
                    Divider()
                        .background(.semanticColor.divider_1pxStrong)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.semanticColor.border_primary, lineWidth: 1)
        )
    }
}

// MARK: - Inline Text

private struct InlineText: View {
    let children: [MarkdownNode]
    var pointColor: Color = SemanticColor().text_strong

    var body: some View {
        Text(attributedString)
            .tint(pointColor)   // 링크에는 SwiftUI의 tint가 적용된다
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedString: AttributedString {
        children.reduce(AttributedString()) { $0 + $1.attributedString(pointColor: pointColor) }
    }
}

private extension MarkdownNode {
    func attributedString(pointColor: Color) -> AttributedString {
        switch self {
        case .text(let str):
            return AttributedString(str)

        case .bold(let children):
            var result = children.reduce(AttributedString()) { $0 + $1.attributedString(pointColor: pointColor) }
            result.font = UIFont(name: "Pretendard-SemiBold", size: 14)
            result.foregroundColor = UIColor(pointColor)
            return result

        case .italic(let children):
            var result = children.reduce(AttributedString()) { $0 + $1.attributedString(pointColor: pointColor) }
            result.font = UIFont(name: "Pretendard-RegularItalic", size: 14)
                ?? .italicSystemFont(ofSize: 14)
            return result

        case .boldItalic(let children):
            var result = children.reduce(AttributedString()) { $0 + $1.attributedString(pointColor: pointColor) }
            result.font = UIFont(name: "Pretendard-SemiBold", size: 14)
            result.foregroundColor = UIColor(pointColor)
            return result

        case .code(let str):
            var result = AttributedString(str)
            result.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
            result.backgroundColor = UIColor(ColorPalette.gray100)
            return result

        case .link(let children, let url):
            var result = children.reduce(AttributedString()) { $0 + $1.attributedString(pointColor: pointColor) }
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
