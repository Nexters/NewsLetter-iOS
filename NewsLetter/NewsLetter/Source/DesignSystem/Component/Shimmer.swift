//
//  Shimmer.swift
//  NewsLetter
//
//  Created by Claude on 7/5/26.
//

import SwiftUI

/// 스켈레톤 로딩 뷰 위에 좌→우로 흐르는 반짝임 효과를 얹습니다.
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    private let duration: Double = 1.2
    private let highlight = ColorPalette.white.opacity(0.5)

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, highlight, .clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: phase * geo.size.width * 1.5)
                }
                .allowsHitTesting(false)
            }
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    /// 스켈레톤 뷰에 반짝임 애니메이션을 적용합니다.
    func shimmering() -> some View {
        modifier(Shimmer())
    }
}
