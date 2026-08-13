//
//  MarkdownDetailView.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import SwiftUI
import UIKit

struct MarkdownDetailView: View {
    /// 마크다운 본문 로드 상태
    enum LoadState: Equatable {
        case loading
        case loaded(String)
        case failed
    }

    let title: String
    /// 본문 상단에 표기할 출처 이름 (뉴스레터명)
    let sourceName: String
    /// 복사 버튼으로 제공할 원문 아티클 링크
    let sourceURL: String
    let pointColor: Color
    let state: LoadState
    @Binding var isPresented: Bool

    @State private var isCopied: Bool = false

    private var nodes: [MarkdownNode] {
        guard case .loaded(let markdown) = state else { return [] }
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

                Text(title)
                    .font(.body16_semiBold)
                    .foregroundStyle(navTitleColor)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(navBackgroundColor)

            Divider()
                .background(dividerColor)

            switch state {
            case .loading:
                Spacer()
                ProgressView()
                Spacer()

            case .loaded:
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 출처는 본문 첫 제목 바로 아래에 붙인다
                        if let firstHeading = nodes.first, case .heading = firstHeading {
                            BlockNodeView(node: firstHeading, pointColor: displayPointColor, isDarkTheme: isDarkTheme)
                            sourceRow
                            ForEach(Array(nodes.dropFirst().enumerated()), id: \.offset) { _, node in
                                BlockNodeView(node: node, pointColor: displayPointColor, isDarkTheme: isDarkTheme)
                            }
                        } else {
                            sourceRow
                            ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
                                BlockNodeView(node: node, pointColor: displayPointColor, isDarkTheme: isDarkTheme)
                            }
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
    }

    private var sourceRow: some View {
        HStack(spacing: 6) {
            Text("출처: \(sourceName)")
                .font(.caption11_regular)
                .foregroundStyle(sourceTextColor)

            Button {
                UIPasteboard.general.string = sourceURL
                isCopied = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    isCopied = false
                }
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: isCopied ? "checkmark" : "link")
                        .font(.system(size: 10, weight: .semibold))
                    Text(isCopied ? "복사됨" : "원문 링크 복사")
                        .font(.caption11_semiBold)
                }
                .foregroundStyle(bodyTextColor)
            }
        }
    }
}

private extension Color {
    static var semanticColor: SemanticColor { SemanticColor() }
}

private let previewMarkdown = """
## 프리뷰 제목

프리뷰 본문입니다.

### 중간 제목

* **볼드 항목:** 본문 설명
"""

#Preview("오렌지 포인트") {
    MarkdownDetailView(
        title: "안드로이드 위클리",
        sourceName: "안드로이드 위클리",
        sourceURL: "https://example.com",
        pointColor: ColorPalette.pointOrange500,
        state: .loaded(previewMarkdown),
        isPresented: .constant(true)
    )
}

#Preview("노란 포인트") {
    MarkdownDetailView(
        title: "레몬 뉴스레터",
        sourceName: "레몬 뉴스레터",
        sourceURL: "https://example.com",
        pointColor: ColorPalette.pointLemonYellow700,
        state: .loaded(previewMarkdown),
        isPresented: .constant(true)
    )
}

#Preview("로딩") {
    MarkdownDetailView(
        title: "퍼플 뉴스레터",
        sourceName: "퍼플 뉴스레터",
        sourceURL: "https://example.com",
        pointColor: ColorPalette.pointPurple600,
        state: .loading,
        isPresented: .constant(true)
    )
}

#Preview("실패") {
    MarkdownDetailView(
        title: "퍼플 뉴스레터",
        sourceName: "퍼플 뉴스레터",
        sourceURL: "https://example.com",
        pointColor: ColorPalette.pointPurple600,
        state: .failed,
        isPresented: .constant(true)
    )
}
