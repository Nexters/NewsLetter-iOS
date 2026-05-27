//
//  SpeechBubble.swift
//  NewsLetter
//

import SwiftUI

// 아래쪽 꼬리가 달린 말풍선 Shape
private struct SpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 24
    var tailWidth: CGFloat = 16
    var tailHeight: CGFloat = 8
    var tailOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let b = rect.minY
        let t = rect.maxY - tailHeight
        let l = rect.minX
        let r = rect.maxX
        let cr = cornerRadius

        // 상단 좌측 모서리
        path.move(to: CGPoint(x: l + cr, y: b))
        // 상단 우측 모서리
        path.addLine(to: CGPoint(x: r - cr, y: b))
        path.addQuadCurve(to: CGPoint(x: r, y: b + cr), control: CGPoint(x: r, y: b))
        // 우측 하단 모서리
        path.addLine(to: CGPoint(x: r, y: t - cr))
        path.addQuadCurve(to: CGPoint(x: r - cr, y: t), control: CGPoint(x: r, y: t))
        // 꼬리 우측
        path.addLine(to: CGPoint(x: l + tailOffset + tailWidth / 2, y: t))
        // 꼬리 끝
        path.addLine(to: CGPoint(x: l + tailOffset, y: rect.maxY))
        // 꼬리 좌측
        path.addLine(to: CGPoint(x: l + tailOffset - tailWidth / 2, y: t))
        // 좌측 하단 모서리
        path.addLine(to: CGPoint(x: l + cr, y: t))
        path.addQuadCurve(to: CGPoint(x: l, y: t - cr), control: CGPoint(x: l, y: t))
        // 좌측 상단 모서리
        path.addLine(to: CGPoint(x: l, y: b + cr))
        path.addQuadCurve(to: CGPoint(x: l + cr, y: b), control: CGPoint(x: l, y: b))
        path.closeSubpath()
        return path
    }
}

struct SpeechBubble: View {
    var emoji: String = "🔥"
    var text: String
    private let tailHeight: CGFloat = 8

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.body13_semiBold)
            Text(text)
                .font(.body13_semiBold)
                .foregroundStyle(ColorPalette.gray950)
        }
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .padding(.vertical, 12)
        .padding(.bottom, tailHeight)
        .background(
            GeometryReader { geo in
                SpeechBubbleShape(tailOffset: geo.size.width / 2)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
            }
        )
    }
}

#Preview {
    ZStack {
        ColorPalette.gray100
        SpeechBubble(text: "함께 읽으면 더 좋은 인기 콘텐츠")
    }
}
