//
//  RecommendSkeletonCardCell.swift
//  NewsLetter
//
//  Created by Claude on 7/5/26.
//

import SwiftUI

/// 추천탭 카드 데이터가 아직 없을 때(로딩 중이거나 7개 미만) 자리를 채우는 스켈레톤 카드입니다.
/// `RecommendCardCell`의 레이아웃/여백을 그대로 미러링해 실 카드와 높이·정렬을 맞춥니다.
struct RecommendSkeletonCardCell: View {
    private enum Metric {
        static let commonPadding: CGFloat = 24
        static let blockColor = ColorPalette.gray200
        static let cardColor = ColorPalette.gray100
    }

    var body: some View {
        VStack(spacing: 0) {
            // 트렌딩 카드의 SpeechBubble 높이만큼 공간 예약 (실 비-트렌딩 카드와 동일)
            SpeechBubble(text: "함께 읽으면 더 좋은 인기 콘텐츠")
                .padding(.bottom, 12)
                .opacity(0.0)

            VStack(alignment: .leading, spacing: 0) {
                // 제목 자리 (2줄)
                VStack(alignment: .leading, spacing: 6) {
                    bar(width: nil, height: 16)
                    bar(width: 160, height: 16)
                }
                .padding(.top, Metric.commonPadding)
                .padding(.horizontal, Metric.commonPadding)

                // 메타(직군 · 출처) 자리
                bar(width: 120, height: 12)
                    .padding(.top, 8)
                    .padding(.leading, Metric.commonPadding)

                // 이미지 자리
                RoundedRectangle(cornerRadius: 16)
                    .fill(Metric.blockColor)
                    .frame(height: 150)
                    .padding(.top, 20)
                    .padding(.horizontal, Metric.commonPadding)
                    .padding(.bottom, 34)
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(Metric.cardColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shimmering()
        }
    }

    private func bar(width: CGFloat?, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Metric.blockColor)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

#Preview {
    RecommendSkeletonCardCell()
        .frame(width: UIScreen.main.bounds.width * 0.8)
}
