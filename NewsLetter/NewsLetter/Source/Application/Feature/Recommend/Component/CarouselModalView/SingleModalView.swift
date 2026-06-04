//
//  SingleModalView.swift
//  NewsLetter
//
//  Created by 이원빈 on 5/3/26.
//

import SwiftUI

import ComposableArchitecture

struct SingleModalView: View {
    private enum Metric {
        static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
        static let cardHeight: CGFloat = 366
        static let xButtonSize: CGFloat = 44
    }
    
    @Binding var isPresented: Bool
    
    let index: Int
    let cardData: Card
    let pointColor: Color
    let firstLookHandler: () -> Void
    
    var body: some View {
        ZStack {
            Color.semanticColor.background_dimmed
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 0) {

                CarouselCard(
                    card: cardData,
                    index: index,
                    pointColor: pointColor,
                    isShareEnabled: true,
                    cardType: index == 0 ? "trending" : "recommend"
                )
                .frame(width: Metric.cardWidth, height: Metric.cardHeight)

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
        .onAppear {
            GA.main_contents_detail_pageview(
                cardIndex: index,
                cardType: index == 0 ? "trending" : "recommend",
                contentType: cardData.kind.gaContentType,
                contentTitle: cardData.title,
                contentId: cardData.id
            )
        }
    }
}

#Preview {
    SingleModalView(
        isPresented: .constant(true),
        index: 0,
        cardData: .stub(),
        pointColor: ColorPalette.pointOrange500,
        firstLookHandler: {}
    )
}
