//
//  CarouselCard.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

struct CarouselCard: View {
    private enum Metric {
        static let height: CGFloat = 366
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 20
        static let nextButtonCornerRadius: CGFloat = 100
        static let nextButtonHeight: CGFloat = 44
    }
    let card: Card
    let pointColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.title)
                .font(.head20_bold)
                .foregroundStyle(pointColor)
            
            Text(card.keyword)
                .font(.body13_medium)
                .foregroundStyle(pointColor)
                .padding(.top, 4)
            
            Text(card.description)
                .font(.body14_regular)
                .padding(.top, 16)
            
            RoundedRectangle(cornerRadius: Metric.nextButtonCornerRadius)
                .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                .background(ColorPalette.white)
                .frame(height: Metric.nextButtonHeight)
                .overlay {
                    Text("이어서 보기")
                        .font(.body14_semiBold)
                        .foregroundStyle(.semanticColor.text_primary)
                }
                .onTapGesture {
                    // TODO: 카드 상세화면으로 넘어가기
                    print("hello world")
                }
                .padding(.top, 16)
        }
        .padding(Metric.padding)
        .frame(height: Metric.height)
        .background(ColorPalette.white)
        .cornerRadius(Metric.cornerRadius)
    }
}

#Preview {
    CarouselCard(card: .stub(), pointColor: ColorPalette.pointPink500)
}
