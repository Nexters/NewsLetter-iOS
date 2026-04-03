//
//  CardView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/19/25.
//

import SwiftUI

struct CardView: View {
    let style: CardTypeStyle
    let color: Color
    let title: String
    let category: String
    let source: String
    let shouldMoveY: CGFloat
    var onTap: (() -> Void)? = nil
    var onTapBegan: (() -> Void)? = nil

    // 제목 최대 28글자까지
    var trimmedTitle: String {
        String(title.prefix(28))
    }

    @Binding var isPresentModal: Bool

    @State private var titleHeight: CGFloat = 0
    @State private var hideCategoryAndSource: Bool = false
    @State private var vStackHeight: CGFloat = 0
    @State private var titleBottomSpacing: CGFloat = 0
    @State private var categoryBottomSpacing: CGFloat = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var cardWidth: CGFloat? = nil
    @State private var cardHeight: CGFloat? = nil
    @State private var cardOffsetY: CGFloat = 0
    @State private var cardZIndex: Double = Z.cardDefault
    @State private var isTapped: Bool = false

    private enum TapAnimation {
        static let springDuration: TimeInterval = 0.5
        static let expandDelay: TimeInterval = 0.5
        static let expandDuration: TimeInterval = 0.5
        static let totalDuration: TimeInterval = expandDelay + expandDuration
    }

    static let tapAnimationTotalDuration: TimeInterval = TapAnimation.totalDuration

    init(
        style: CardTypeStyle,
        color: Color,
        title: String,
        category: String,
        source: String,
        shouldMoveY: CGFloat,
        onTap: (() -> Void)? = nil,
        onTapBegan: (() -> Void)? = nil,
        isPresentModal: Binding<Bool>
    ) {
        self.style = style
        self.color = color
        self.title = title
        self.category = category
        self.source = source
        self.shouldMoveY = shouldMoveY
        self.onTap = onTap
        self.onTapBegan = onTapBegan
        self._isPresentModal = isPresentModal
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(trimmedTitle)
                    .fontRangeLimited()
                    .font(style.fontName)
                    .foregroundStyle(.semanticColor.text_strong)
                    .padding(.top, hideCategoryAndSource ? 16 : style.topPadding)
                    .padding(.bottom, titleBottomSpacing)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    updateTitleLayout(height: proxy.size.height)
                                }
                                .onChange(of: proxy.size.height) { _, newValue in
                                    DispatchQueue.main.async {
                                        updateTitleLayout(height: newValue)
                                    }
                                }
                        }
                    )

                if !hideCategoryAndSource {
                    HStack(spacing: 6) {
                        Text(category)
                            .fontRangeLimited()
                            .font(UIDevice.isSmallScreen ? .caption12_medium : .body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))

                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundStyle(ColorPalette.black.opacity(0.1))

                        Text(source)
                            .fontRangeLimited()
                            .font(UIDevice.isSmallScreen ? .caption12_medium : .body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))
                    }
                    .padding(.bottom, UIDevice.isSmallScreen ? 4 : style.bottomPadding)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, categoryBottomSpacing)
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
        .padding([.leading, .trailing], isTapped ? 0 : style.sidePadding)
        .frame(width: cardWidth, height: cardHeight)
        .offset(y: cardOffsetY)
        .scaleEffect(cardScale)
        .zIndex(cardZIndex)
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            onTapBegan?()
            withAnimation(.spring(duration: TapAnimation.springDuration)) {
                cardOffsetY = shouldMoveY
                cardZIndex = Z.cardElevated
                cardHeight = 300
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + TapAnimation.expandDelay) {
                withAnimation(.easeInOut(duration: TapAnimation.expandDuration)) {
                    isTapped = true
                    cardWidth = Device.width * 0.8
                    cardHeight = 366
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + TapAnimation.totalDuration) {
                onTap?()
            }
        }
        .onChange(of: isPresentModal) { _, newValue in
            if newValue == false {
                withAnimation(.spring(duration: TapAnimation.springDuration)) {
                    cardOffsetY = 0
                    isTapped = false
                    cardWidth = nil
                    cardHeight = vStackHeight == 0 ? nil : vStackHeight + 35
                    cardZIndex = Z.cardDefault
                }
            }
        }
        .onAppear {
            cardHeight = vStackHeight == 0 ? nil : vStackHeight + 35
        }
    }

    private func updateTitleLayout(height: CGFloat) {
        let calculatedTitleHeight = height - (hideCategoryAndSource ? 16 : style.topPadding) - titleBottomSpacing

        if abs(titleHeight - calculatedTitleHeight) > 0.5 || titleHeight == 0 {
            titleHeight = calculatedTitleHeight

            if style.depth < 3 {
                let shouldHide = calculatedTitleHeight >= style.oneLineHeight
                if hideCategoryAndSource != shouldHide {
                    hideCategoryAndSource = shouldHide
                    titleBottomSpacing = shouldHide
                        ? (style.depth >= 1 && style.depth < 2 ? 12 : style.bottomPadding)
                        : 4
                }
            } else {
                hideCategoryAndSource = false
                titleBottomSpacing = 4
                let shouldHide = calculatedTitleHeight >= style.oneLineHeight
                if !shouldHide {
                    categoryBottomSpacing = UIDevice.isSmallScreen ? CGFloat(4) : style.oneLineHeight
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: -35) {
        CardView(style: CardType.one.style, color: .accentColor.purple, title: "사이드 프로젝트, AI로 출시까지? 지금 바로", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, onTap: { print("===") }, isPresentModal: .constant(false))
        CardView(style: CardType.two.style, color: .accentColor.orange, title: "SwiftUI 한 줄 코드로 번역? 믿기지 않죠!", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, isPresentModal: .constant(false))
        CardView(style: CardType.three.style, color: .accentColor.skyblue, title: "일이삼사오육칠팔구십일이삼사오육칠", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, isPresentModal: .constant(false))
        CardView(style: CardType.four.style, color: .accentColor.lemonyellow, title: "직장인이라면 알아야 할 주 4일제의 모든 것", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, isPresentModal: .constant(false))
        CardView(style: CardType.five.style, color: .accentColor.pink, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, isPresentModal: .constant(false))
        CardView(style: CardType.six.style, color: .accentColor.green, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리", shouldMoveY: 0, isPresentModal: .constant(false))
    }
}
