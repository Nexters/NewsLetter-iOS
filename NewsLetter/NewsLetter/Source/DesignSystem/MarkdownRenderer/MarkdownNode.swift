import Foundation

// MARK: - Markdown AST Node

indirect enum MarkdownNode {
    // Block elements
    case heading(level: Int, children: [MarkdownNode])
    case paragraph(children: [MarkdownNode])
    case codeBlock(language: String?, code: String)
    case blockquote(children: [MarkdownNode])
    case callout(type: CalloutType, children: [MarkdownNode])
    case bulletList(items: [[MarkdownNode]])
    case orderedList(items: [[MarkdownNode]])
    case horizontalRule
    case table(header: [String], rows: [[String]])

    // Inline elements
    case text(String)
    case bold(children: [MarkdownNode])
    case italic(children: [MarkdownNode])
    case boldItalic(children: [MarkdownNode])
    case code(String)
    case lineBreak
}

// MARK: - Callout Type

enum CalloutType: String {
    case tip, info, warning, danger, note, important

    var icon: String {
        switch self {
        case .tip:       return "lightbulb"
        case .info:      return "info.circle"
        case .warning:   return "exclamationmark.triangle"
        case .danger:    return "xmark.circle"
        case .note:      return "note.text"
        case .important: return "exclamationmark.circle"
        }
    }

    var label: String { rawValue.capitalized }
}
