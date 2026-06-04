//
//  ExploreCardModalView.swift
//  NewsLetter
//
//  Created by 이원빈 on 12/11/25.
//

import SwiftUI

import ComposableArchitecture

struct ExploreCardModalView: View {
    private enum Metric {
        static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    }

    @Binding var isPresented: Bool
    
    let cardData: Card
    let pointColor: Color
    
    // TODO: Figma 디자인 요구사항에 맞게 고도화 필요.
    var body: some View {
        ZStack {
            Color.semanticColor.background_dimmed2
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image("arrow_left_icon")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .padding(6)
                    }
                    Spacer()
                }
                .frame(height: 44)
                .padding(.leading, 6)
                
                Spacer()
            }

            CarouselCard(
                card: cardData,
                index: 0, // FIXME: index 값 여기선 의미가 없으므로 일단 0 대입
                pointColor: pointColor,
                isShareEnabled: false
            )
            .frame(width: Metric.cardWidth)
        }
    }
}

#Preview {
    ExploreCardModalView(
        isPresented: .constant(true),
        cardData: .stub(),
        pointColor: ColorPalette.pointPurple600,
    )
}
