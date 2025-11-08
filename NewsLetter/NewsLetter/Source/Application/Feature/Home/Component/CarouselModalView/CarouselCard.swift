//
//  CarouselCard.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI
import WebKit

import FirebaseAnalytics

struct CarouselCard: View {
    private enum Metric {
        static let height: CGFloat = 366
        static let smallCornerRadius: CGFloat = 4
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 20
        static let shareButtonSize: CGFloat = 44
        static let nextButtonCornerRadius: CGFloat = 100
        static let nextButtonHeight: CGFloat = 44
    }

    @StateObject private var kakaoShareManager = KakaoShareManager()
    @State private var isWebViewPresented: Bool = false
    let card: Card
    let index: Int
    let pointColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.title)
                .fontRangeLimited()
                .font(.head20_bold)
                .foregroundStyle(pointColor)

            HStack(spacing: 6) {
//                Text("한국어")
//                  .font(.caption11_bold)
//                  .padding(.horizontal, 6)
//                  .padding(.vertical, 2)
//                  .foregroundStyle(ColorPalette.white)
//                  .background(
//                    RoundedRectangle(cornerRadius: Metric.smallCornerRadius)
//                      .fill(pointColor)
//                  )

                Text(card.topKeyword)
                    .font(.body13_medium)
                
                Rectangle()
                    .frame(width: 1, height: 14)
                
                Text(card.newsletterName)
                    .fontRangeLimited()
                    .font(.body13_medium)
            }
            .foregroundStyle(pointColor)
            .padding(.top, 4)
            
            Text(card.summary)
                .fontRangeLimited()
                .font(.body14_regular)
                .padding(.top, 16)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    Task {
                        await kakaoShareManager.shareToKakao(
                            title: card.title,
                            id: card.id,
                            textColor: pointColor,
                            contentURL: card.contentURL
                        )
                    }
                } label: {
                    RoundedRectangle(cornerRadius: Metric.shareButtonSize/2)
                        .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                        .background(ColorPalette.white)
                        .frame(width: Metric.shareButtonSize, height: Metric.shareButtonSize)
                        .overlay {
                            Image("share_icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.semanticColor.text_primary)

                        }
                }
                .foregroundStyle(.semanticColor.text_primary)

                Button {
                    isWebViewPresented = true

                    GA.click_newsletter_carousel(title: card.title, listIndex: index)
                } label: {
                    RoundedRectangle(cornerRadius: Metric.nextButtonCornerRadius)
                        .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                        .background(ColorPalette.white)
                        .frame(height: Metric.nextButtonHeight)
                        .overlay {
                            Text("원문 보기")
                                .fontRangeLimited()
                                .font(.body14_semiBold)
                                .foregroundStyle(.semanticColor.text_primary)
                        }
                }
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
    CarouselCard(card: .stub(), index: 0, pointColor: ColorPalette.pointPink500)
}
