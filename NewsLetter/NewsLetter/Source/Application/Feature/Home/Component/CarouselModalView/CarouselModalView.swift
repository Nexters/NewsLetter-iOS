//
//  CarouselModalView.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

struct CarouselModalView: View {

    private enum Metric {
        static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
        static let cardSpacing: CGFloat = 12
        static let cardStackHorizontalPadding: CGFloat = (UIScreen.main.bounds.width - Metric.cardWidth) / 2
        static let scrollViewHeight: CGFloat = 366
        static let indicatorSize: CGFloat = 8
        static let xButtonSize: CGFloat = 44
        static let pointColorSet = [
            ColorPalette.pointPurple600,
            ColorPalette.pointOrange500,
            ColorPalette.pointBlue600,
            ColorPalette.pointLemonYellow700,
            ColorPalette.pointPink600,
            ColorPalette.pointGreen600
        ]
    }

    @Binding var isPresented: Bool
    @Binding var currentPage: Int?

    let cardData: [Card]
    let firstLookHandler: () -> Void

    var body: some View {
        let reversedCardData = Array(cardData.reversed())
        let reversedPointColors = Array(Metric.pointColorSet.reversed())

        ZStack {
            Color.semanticColor.background_dimmed
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Metric.cardSpacing) {
                        ForEach(reversedCardData.indices, id: \.self) { index in
                            let card = reversedCardData[index]
                            let pointColor = reversedPointColors[index]
                            CarouselCard(card: card, pointColor: pointColor)
                                .frame(width: Metric.cardWidth)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, Metric.cardStackHorizontalPadding, for: .scrollContent)
                .frame(height: Metric.scrollViewHeight)
                .scrollPosition(id: Binding<Int?>(
                    get: {
                        guard let page = self.currentPage else { return nil }
                        return (cardData.count - 1) - page
                    },
                    set: { reversedId in
                        if let id = reversedId {
                            self.currentPage = (cardData.count - 1) - id
                        }
                    }
                ))

                HStack(spacing: Metric.indicatorSize) {
                    ForEach(0..<cardData.count, id: \.self) { index in
                        Circle()
                            .fill(index == (cardData.count - 1) - (currentPage ?? 0) ? Color.white : Color.gray.opacity(0.5))
                            .frame(width: Metric.indicatorSize, height: Metric.indicatorSize)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 16)

                Button {
                    if UserActionHistory.isFirstLook == false {
                        UserActionHistory.isFirstLook = true
                        firstLookHandler()
                    }
                    isPresented = false
                } label: {
                    Image("xbutton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Metric.xButtonSize, height: Metric.xButtonSize)
                }
                .padding(.top, 43)
            }
        }
    }
}

#Preview {
    CarouselModalView(isPresented: .constant(true),
                      currentPage: .constant(2),
                      cardData: Array(repeating: .stub(), count: 6),
                      firstLookHandler: {}
    )
}

