//
//  CarouselModalView.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

import ComposableArchitecture

struct CarouselModalView: View {
    private enum Metric {
        static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
        static let cardSpacing: CGFloat = 12
        static let cardStackHorizontalPadding: CGFloat = (UIScreen.main.bounds.width - Metric.cardWidth) / 2
        static let scrollViewHeight: CGFloat = 366
        static let indicatorSize: CGFloat = 8
        static let xButtonSize: CGFloat = 44
    }

    @State var cardData: [Card]
    @State var pointColors: [Color]
    @Binding var isPresented: Bool
    @Binding var currentPage: Int?

    let firstLookHandler: () -> Void

    var body: some View {
        let cardData = Array(cardData.reversed())
        let pointColors = Array(pointColors.reversed()
            .dropFirst(pointColors.count - cardData.count))
            .map { $0.toChangeColor() }

        ZStack {
            Color.semanticColor.background_dimmed
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Metric.cardSpacing) {
                        ForEach(cardData.indices, id: \.self) { index in
                            let card = cardData[index]
                            let pointColor = pointColors[index]
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

// 카드 컬러 받아서 캐로셀 글씨 컬러로 변경해주는 함수
extension Color {
    func toChangeColor() -> Color {
        switch self {
        case ColorPalette.pointPurple150, ColorPalette.pointPurple200, ColorPalette.pointPurple300:
            return ColorPalette.pointPurple600

        case ColorPalette.pointOrange300, ColorPalette.pointOrange400, ColorPalette.pointOrange500:
            return ColorPalette.pointOrange500

        case ColorPalette.pointBlue200, ColorPalette.pointBlue300, ColorPalette.pointBlue400:
            return ColorPalette.pointBlue600

        case ColorPalette.pointLemonYellow200, ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellow400:
            return ColorPalette.pointLemonYellow700

        case ColorPalette.pointPink200, ColorPalette.pointPink300, ColorPalette.pointPink400:
            return ColorPalette.pointPink600

        case ColorPalette.pointGreen200, ColorPalette.pointGreen300, ColorPalette.pointGreen400:
            return ColorPalette.pointGreen600

        default:
            return self
        }
    }
}

#Preview {
    CarouselModalView(
        cardData: Array(repeating: .stub(), count: 6),
        pointColors: [
            ColorPalette.pointPurple600,
            ColorPalette.pointOrange500,
            ColorPalette.pointBlue600,
            ColorPalette.pointLemonYellow700,
            ColorPalette.pointPink600,
            ColorPalette.pointGreen600
        ],
        isPresented: .constant(true),
        currentPage: .constant(2),
        firstLookHandler: {}
    )
}
