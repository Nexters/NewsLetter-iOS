//
//  CardTypeStyle.swift
//  NewsLetter
//
//  Created by 이조은 on 1/28/26.
//

import SwiftUI

struct CardTypeStyle {
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    var sidePadding: CGFloat
    var oneLineHeight: CGFloat
    var fontName: FontStyle
    var depth: CGFloat  // 0.0(.one) ~ 5.0(.six)
}


extension CardType {
    var depth: CGFloat {
        switch self {
        case .one: return 0
        case .two: return 1
        case .three: return 2
        case .four: return 3
        case .five: return 4
        case .six: return 5
        }
    }

    var style: CardTypeStyle {
        CardTypeStyle(
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            sidePadding: sidePadding,
            oneLineHeight: CGFloat(oneLineHeight),
            fontName: UIDevice.isSmallScreen || UIDevice.is13MiniScreen ? fontNameSE : fontName,
            depth: depth
        )
    }

    static func fromIndex(_ i: Int) -> CardType {
        switch i {
        case 0: return .one
        case 1: return .two
        case 2: return .three
        case 3: return .four
        case 4: return .five
        default: return .six
        }
    }
}

func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    a + (b - a) * t
}

func interpolatedStyle(depth: CGFloat) -> CardTypeStyle {
    let clamped = min(max(depth, 0), 5)
    let lower = Int(floor(clamped))
    let upper = min(lower + 1, 5)
    let t = clamped - CGFloat(lower)

    let s0 = CardType.fromIndex(lower).style
    let s1 = CardType.fromIndex(upper).style

    let top = lerp(s0.topPadding, s1.topPadding, t)
    let bottom = lerp(s0.bottomPadding, s1.bottomPadding, t)
    let side = lerp(s0.sidePadding, s1.sidePadding, t)
    let lineH = lerp(s0.oneLineHeight, s1.oneLineHeight, t)

    let fontName = (t < 0.5) ? s0.fontName : s1.fontName

    return CardTypeStyle(
        topPadding: top,
        bottomPadding: bottom,
        sidePadding: side,
        oneLineHeight: lineH,
        fontName: fontName,
        depth: clamped
    )
}
