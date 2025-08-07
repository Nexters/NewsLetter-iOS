//
//  CardView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/19/25.
//

import SwiftUI

struct CardView: View {
    let cardType: CardType
    let color: Color
    let title: String
    let category: String
    let source: String
    var onTap: (() -> Void)? = nil

    // 제목 최대 28글자까지
    var trimmedTitle: String {
        String(title.prefix(28))
    }

    @State private var titleHeight: CGFloat = 0
    @State private var hideCategoryAndSource: Bool = false
    @State private var vStackHeight: CGFloat = 0
    @State private var titleBottomSpacing: CGFloat = 0
    @State private var cardScale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(trimmedTitle)
                    .font(cardType.fontName)
                    .foregroundStyle(.semanticColor.text_strong)
                    .padding(.top, hideCategoryAndSource ? 16 : cardType.topPadding)
                    .padding(.bottom, titleBottomSpacing)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    let newHeight = proxy.size.height
                                    let calculatedTitleHeight = newHeight - (hideCategoryAndSource ? 16 : cardType.topPadding) - titleBottomSpacing
                                    self.titleHeight = calculatedTitleHeight

                                    if cardType == .one || cardType == .two || cardType == .three {
                                        let shouldHide = calculatedTitleHeight >= CGFloat(cardType.oneLineHeight)
                                        if hideCategoryAndSource != shouldHide {
                                            hideCategoryAndSource = shouldHide
                                            titleBottomSpacing = shouldHide
                                            ? (cardType == .two ? 12 : cardType.bottomPadding)
                                            : 4
                                        }
                                    } else {
                                        hideCategoryAndSource = false
                                        titleBottomSpacing = 4
                                    }
                                }
                                .onChange(of: proxy.size.height) { _, newValue in
                                    let calculatedTitleHeight = newValue - (hideCategoryAndSource ? 16 : cardType.topPadding) - titleBottomSpacing

                                    if abs(titleHeight - calculatedTitleHeight) > 0.5 {
                                        titleHeight = calculatedTitleHeight

                                        if cardType == .one || cardType == .two || cardType == .three {
                                            let shouldHide = calculatedTitleHeight >= CGFloat(cardType.oneLineHeight)
                                            if hideCategoryAndSource != shouldHide {
                                                hideCategoryAndSource = shouldHide
                                                titleBottomSpacing = shouldHide
                                                ? (cardType == .two ? 12 : cardType.bottomPadding)
                                                : 4
                                            }
                                        } else {
                                            hideCategoryAndSource = false
                                            titleBottomSpacing = 4
                                        }
                                    }
                                }
                        }
                    )

                if !hideCategoryAndSource {
                    HStack(spacing: 6) {
                        Text(category)
                            .font(.body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))

                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundStyle(ColorPalette.black.opacity(0.1))

                        Text(source)
                            .font(.body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))
                    }
                    .padding(.bottom, cardType.bottomPadding)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 0)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            self.vStackHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size.height) { _, newValue in
                            self.vStackHeight = newValue
                        }
                }
            )
        }
        .padding([.leading, .trailing], cardType.sidePadding)
        .frame(height: vStackHeight == 0 ? nil : vStackHeight + 35)
        .scaleEffect(cardScale)
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            withAnimation(.easeInOut(duration: 0.15)) {
                cardScale = 1.03
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    cardScale = 1.0
                }
            }

            onTap?()
        }
    }
}

#Preview {
    VStack(spacing:-35) {
        CardView(cardType: .one, color: .accentColor.purple, title: "사이드 프로젝트, AI로 출시까지? 지금 바로", category: "Kotlin", source: "안드로이드 위클리",onTap: {print("===")})
        CardView(cardType: .two, color: .accentColor.orange, title: "SwiftUI 한 줄 코드로 번역? 믿기지 않죠!", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .three, color: .accentColor.skyblue, title: "일이삼사오육칠팔구십일이삼사오육칠", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .four, color: .accentColor.lemonyellow, title: "직장인이라면 알아야 할 주 4일제의 모든 것", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .five, color: .accentColor.pink, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .six, color: .accentColor.green, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
    }
}
