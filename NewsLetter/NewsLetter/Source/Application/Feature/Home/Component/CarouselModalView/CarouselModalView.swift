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
            ColorPalette.pointGreen600,
            ColorPalette.pointPink600,
            ColorPalette.pointLemonYellow700,
            ColorPalette.pointBlue600,
            ColorPalette.pointOrange500,
            ColorPalette.pointPurple600
        ]
    }
    
    @Binding var isPresented: Bool
    @Binding var currentPage: Int?
    
    let cards: [Card] = Array(repeating: .stub(), count: 6)
    let firstLookHandler: () -> Void
    
    var body: some View {
        ZStack {
            Color.semanticColor.background_dimmed
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Metric.cardSpacing) {
                        ForEach(cards.indices, id: \.self) { index in
                            let card = cards[index]
                            CarouselCard(card: card, pointColor: Metric.pointColorSet[index])
                                .frame(width: Metric.cardWidth)
                        }
                    }
                    .padding(.horizontal, Metric.cardStackHorizontalPadding)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .frame(height: Metric.scrollViewHeight)
                .scrollPosition(id: Binding<Int?>(
                    get: { self.currentPage },
                    set: { id in
                        if let id = id {
                            self.currentPage = id
                        }
                    }
                ))
                
                HStack(spacing: Metric.indicatorSize) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
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
    CarouselModalView(isPresented: .constant(true), currentPage: .constant(2), firstLookHandler: {})
}

