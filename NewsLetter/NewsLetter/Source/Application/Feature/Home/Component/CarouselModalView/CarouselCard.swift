//
//  CarouselCard.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI
import WebKit

struct CarouselCard: View {
    private enum Metric {
        static let height: CGFloat = 366
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 20
        static let nextButtonCornerRadius: CGFloat = 100
        static let nextButtonHeight: CGFloat = 44
    }
    
    @State private var isWebViewPresented: Bool = false
    let card: Card
    let pointColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.title)
                .font(.head20_bold)
                .foregroundStyle(pointColor)
            
            Text(card.topKeyword)
                .font(.body13_medium)
                .foregroundStyle(pointColor)
                .padding(.top, 4)
            
            Text(card.summary)
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
                    isWebViewPresented = true
                }
                .padding(.top, 16)
        }
        .padding(Metric.padding)
        .frame(height: Metric.height)
        .background(ColorPalette.white)
        .cornerRadius(Metric.cornerRadius)
        .fullScreenCover(isPresented: $isWebViewPresented) {
            WebViewFullScreen(
                url: URL(string: card.contentURL)!,
                isPresented: $isWebViewPresented
            )
        }
    }
}

#Preview {
    CarouselCard(card: .stub(), pointColor: ColorPalette.pointPink500)
}
