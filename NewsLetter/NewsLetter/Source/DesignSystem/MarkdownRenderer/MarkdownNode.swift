import Foundation

// MARK: - Markdown AST Node

indirect enum MarkdownNode {
    // Block elements
    case heading(level: Int, children: [MarkdownNode])
    case paragraph(children: [MarkdownNode])
    case codeBlock(language: String?, code: String)
    case blockquote(children: [MarkdownNode])
    case bulletList(items: [[MarkdownNode]])
    case orderedList(items: [OrderedListItem])
    case horizontalRule
    case table(header: [String], rows: [[String]])

    // Inline elements
    case text(String)
    case bold(children: [MarkdownNode])
    case italic(children: [MarkdownNode])
    case boldItalic(children: [MarkdownNode])
    case code(String)
    case link(children: [MarkdownNode], url: String)
    case lineBreak
}

// MARK: - Ordered List Item

/// 번호 매기기 목록의 한 항목. 원문에 적힌 번호를 그대로 보존한다.
struct OrderedListItem {
    let number: Int
    let children: [MarkdownNode]
}
