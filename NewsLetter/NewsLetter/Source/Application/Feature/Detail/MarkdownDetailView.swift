//
//  MarkdownDetailView.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import SwiftUI
import UIKit

import ComposableArchitecture

struct MarkdownDetailView: View {
    // 이 화면을 띄우는 모달 체인(CarouselModalView → CarouselCard)이 store 없이 동작하므로,
    // 상세 화면이 자신의 store를 직접 소유한다. 본문 로드는 전부 Reducer가 담당한다.
    @State private var store: StoreOf<MarkdownDetailReducer>

    let pointColor: Color
    @Binding var isPresented: Bool

    @State private var isLinkCopiedToastPresented: Bool = false

    init(exposureContentId: Int, pointColor: Color, isPresented: Binding<Bool>) {
        self.init(
            store: Store(initialState: MarkdownDetailReducer.State(exposureContentId: exposureContentId)) {
                MarkdownDetailReducer()
            },
            pointColor: pointColor,
            isPresented: isPresented
        )
    }

    init(store: StoreOf<MarkdownDetailReducer>, pointColor: Color, isPresented: Binding<Bool>) {
        self._store = State(initialValue: store)
        self.pointColor = pointColor
        self._isPresented = isPresented
    }

    private var nodes: [MarkdownNode] {
        guard case .loaded(let markdown) = store.loadState else { return [] }
        return MarkdownParser().parse(markdown)
    }

    // 컬러 패밀리별로 다크 배경에서 대비가 확보되는 밝은 톤을 매핑한다
    private static let darkThemeDisplayColors: [Color: Color] = {
        func family(_ tokens: [Color], display: Color) -> [(Color, Color)] {
            tokens.map { ($0, display) }
        }

        let entries =
            family(
                [
                    ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellow400,
                    ColorPalette.pointLemonYellow500, ColorPalette.pointLemonYellow600,
                    ColorPalette.pointLemonYellow700, ColorPalette.pointLemonYellow800,
                    ColorPalette.pointLemonYellow900, ColorPalette.pointLemonYellowTextPrimary
                ],
                display: ColorPalette.pointLemonYellow300
            )
            + family(
                [
                    ColorPalette.pointPurple300, ColorPalette.pointPurple400,
                    ColorPalette.pointPurple500, ColorPalette.pointPurple600,
                    ColorPalette.pointPurple700, ColorPalette.pointPurple800,
                    ColorPalette.pointPurple900, ColorPalette.pointPurpleTextPrimary
                ],
                display: ColorPalette.pointPurple300
            )
            + family(
                [
                    ColorPalette.pointOrange400, ColorPalette.pointOrange500,
                    ColorPalette.pointOrange600, ColorPalette.pointOrange700,
                    ColorPalette.pointOrange800, ColorPalette.pointOrange900
                ],
                display: ColorPalette.pointOrange300
            )
            + family(
                [
                    ColorPalette.pointBlue400, ColorPalette.pointBlue500,
                    ColorPalette.pointBlue600, ColorPalette.pointBlue700,
                    ColorPalette.pointBlue800, ColorPalette.pointBlue900
                ],
                display: ColorPalette.pointBlue300
            )
            + family(
                [
                    ColorPalette.pointPink400, ColorPalette.pointPink500,
                    ColorPalette.pointPink600, ColorPalette.pointPink700,
                    ColorPalette.pointPink800, ColorPalette.pointPink900
                ],
                display: ColorPalette.pointPink300
            )
            + family(
                [
                    ColorPalette.pointGreen400, ColorPalette.pointGreen500,
                    ColorPalette.pointGreen600, ColorPalette.pointGreen700,
                    ColorPalette.pointGreen800, ColorPalette.pointGreen900
                ],
                display: ColorPalette.pointGreen300
            )

        return Dictionary(uniqueKeysWithValues: entries)
    }()

    // 마크다운 상세 페이지는 포인트 컬러와 무관하게 항상 다크 배경으로 표시한다
    private var isDarkTheme: Bool { true }

    // 다크 배경에서는 어두운 톤 대신 더 밝은 톤으로 대비를 확보한다
    private var displayPointColor: Color {
        Self.darkThemeDisplayColors[pointColor] ?? pointColor
    }

    private var backgroundColor: Color {
        isDarkTheme ? ColorPalette.gray900 : Color.semanticColor.background_base
    }

    private var navBackgroundColor: Color {
        isDarkTheme ? ColorPalette.gray900 : Color.semanticColor.background_surface
    }

    private var navTitleColor: Color {
        isDarkTheme ? ColorPalette.white : .semanticColor.text_strong
    }

    private var dividerColor: Color {
        isDarkTheme ? ColorPalette.gray700 : .semanticColor.divider_1pxStrong
    }

    private var bodyTextColor: Color {
        isDarkTheme ? ColorPalette.gray200 : .semanticColor.text_primary
    }

    private var sourceTextColor: Color {
        isDarkTheme ? ColorPalette.gray400 : .semanticColor.text_tertiary
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(navTitleColor)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(navBackgroundColor)

            Divider()
                .background(dividerColor)

            switch store.loadState {
            case .loading:
                Spacer()
                ProgressView()
                Spacer()

            case .loaded:
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
                            nodeView(node)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }

            case .failed:
                Spacer()
                Text("본문을 불러오지 못했습니다.\n다시 시도해주세요")
                    .font(.body15_regular)
                    .foregroundStyle(bodyTextColor)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .background(backgroundColor)
        .onAppear { store.send(.onAppear) }
        // 본문 링크는 열지 않고 복사한다
        .environment(\.openURL, OpenURLAction { url in
            copyLink(url.absoluteString)
            return .handled
        })
        .toastMessage(isPresented: $isLinkCopiedToastPresented,
                      text: "링크가 복사되었어요",
                      bottomPadding: 40)
    }

    private func copyLink(_ url: String) {
        UIPasteboard.general.string = url
        isLinkCopiedToastPresented = true
    }

    @ViewBuilder
    private func nodeView(_ node: MarkdownNode) -> some View {
        // 본문에 포함된 출처 줄은 기존 UI와 같은 캡션 스타일 + 링크 복사 버튼으로 표시한다
        if case .paragraph(let children) = node, isSourceLine(children) {
            SourceLineView(
                text: Self.plainText(children),
                link: Self.firstLink(in: children),
                textColor: sourceTextColor,
                linkColor: bodyTextColor,
                onCopy: copyLink
            )
        } else {
            BlockNodeView(node: node, pointColor: displayPointColor, isDarkTheme: isDarkTheme)
        }
    }

    private func isSourceLine(_ children: [MarkdownNode]) -> Bool {
        guard case .text(let first)? = children.first else { return false }
        return first.trimmingCharacters(in: .whitespaces).hasPrefix("출처:")
    }

    /// 링크를 제외한 나머지 텍스트만 이어붙인다
    private static func plainText(_ nodes: [MarkdownNode]) -> String {
        let joined = nodes.reduce(into: "") { result, node in
            switch node {
            case .text(let value), .code(let value):
                result += value
            case .bold(let children), .italic(let children), .boldItalic(let children):
                result += plainText(children)
            case .lineBreak:
                result += " "
            default:
                break
            }
        }
        return joined.trimmingCharacters(in: .whitespaces)
    }

    private static func firstLink(in nodes: [MarkdownNode]) -> (label: String, url: String)? {
        for node in nodes {
            guard case .link(let children, let url) = node else { continue }
            let label = plainText(children)
            return (label.isEmpty ? "원문 링크" : label, url)
        }
        return nil
    }
}

// MARK: - Source Line

/// "출처: OO | 원본 아티클: [원문 읽기](...)" 줄. 링크는 복사 버튼으로 노출한다.
private struct SourceLineView: View {
    let text: String
    let link: (label: String, url: String)?
    let textColor: Color
    let linkColor: Color
    let onCopy: (String) -> Void

    @State private var isCopied: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if !text.isEmpty {
                Text(text)
                    .font(.caption11_regular)
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let link {
                Button {
                    onCopy(link.url)
                    isCopied = true
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        isCopied = false
                    }
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: isCopied ? "checkmark" : "link")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isCopied ? "복사됨" : link.label)
                            .font(.caption11_semiBold)
                    }
                    .foregroundStyle(linkColor)
                }
                .fixedSize()
            }

            Spacer(minLength: 0)
        }
    }
}

private extension Color {
    static var semanticColor: SemanticColor { SemanticColor() }
}

private let previewMarkdown = #"""
# 프리뷰 제목

출처: 프리뷰 뉴스레터 | 원본 아티클: [원문 읽기](https://example.com)

주요 키워드: Android

---\n\n## 📌 에디터 요약\n\n프리뷰 본문입니다.\n\n---\n\n## 📖 아티클 본문\n\n1. 첫 번째 항목
첫 번째 항목 설명
Link: https://example.com/1

2. 두 번째 항목
Link: https://example.com/2

10. 열 번째 항목
Link: https://example.com/10
"""#

#Preview("오렌지 포인트") {
    MarkdownDetailView(
        store: Store(initialState: .init(exposureContentId: 0, loadState: .loaded(previewMarkdown))) { },
        pointColor: ColorPalette.pointOrange500,
        isPresented: .constant(true)
    )
}

#Preview("노란 포인트") {
    MarkdownDetailView(
        store: Store(initialState: .init(exposureContentId: 0, loadState: .loaded(previewMarkdown))) { },
        pointColor: ColorPalette.pointLemonYellow700,
        isPresented: .constant(true)
    )
}

#Preview("로딩") {
    MarkdownDetailView(
        store: Store(initialState: .init(exposureContentId: 0, loadState: .loading)) { },
        pointColor: ColorPalette.pointPurple600,
        isPresented: .constant(true)
    )
}

#Preview("실패") {
    MarkdownDetailView(
        store: Store(initialState: .init(exposureContentId: 0, loadState: .failed)) { },
        pointColor: ColorPalette.pointPurple600,
        isPresented: .constant(true)
    )
}
