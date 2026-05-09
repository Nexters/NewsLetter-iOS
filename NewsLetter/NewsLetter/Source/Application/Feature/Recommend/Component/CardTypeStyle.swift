////
////  CardTypeStyle.swift
////  NewsLetter
////
////  Created by 이조은 on 1/28/26.
////
//
//import SwiftUI
//
//struct CardTypeStyle {
//    var topPadding: CGFloat
//    var bottomPadding: CGFloat
//    var sidePadding: CGFloat
//    var oneLineHeight: CGFloat
//    var fontName: FontStyle
//    var depth: CGFloat  // 0.0(.one) ~ 5.0(.six)
//}
//
//
//extension CardType {
//    var depth: CGFloat {
//        switch self {
//        case .one: return 0
//        case .two: return 1
//        case .three: return 2
//        case .four: return 3
//        case .five: return 4
//        case .six: return 5
//        }
//    }
//
//    var style: CardTypeStyle {
//        CardTypeStyle(
//            topPadding: topPadding,
//            bottomPadding: bottomPadding,
//            sidePadding: sidePadding,
//            oneLineHeight: CGFloat(oneLineHeight),
//            fontName: UIDevice.isSmallScreen || UIDevice.is13MiniScreen ? fontNameSE : fontName,
//            depth: depth
//        )
//    }
//
//    static func fromIndex(_ i: Int) -> CardType {
//        switch i {
//        case 0: return .one
//        case 1: return .two
//        case 2: return .three
//        case 3: return .four
//        case 4: return .five
//        default: return .six
//        }
//    }
//}
//
///// 선형 보간(Linear Interpolation): t(0~1)비율에 따라 a에서 b 사이의 값을 반환
//func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
//    a + (b - a) * t
//}
//
///// 연속적인 depth 값(0.0~5.0)으로부터 카드 스타일을 보간하여 생성
///// 스크롤 시 카드 타입 간 부드러운 전환 애니메이션을 위해 사용
//func interpolatedStyle(depth: CGFloat) -> CardTypeStyle {
//    // depth를 0~5 범위로 클램핑
//    let clamped = min(max(depth, 0), 5)
//    // 인접한 두 카드 타입의 인덱스 산출 (예: depth 2.3 → lower: 2, upper: 3)
//    let lower = Int(floor(clamped))
//    let upper = min(lower + 1, 5)
//    // 두 카드 타입 사이의 보간 비율 (예: depth 2.3 → t: 0.3)
//    let t = clamped - CGFloat(lower)
//
//    let s0 = CardType.fromIndex(lower).style
//    let s1 = CardType.fromIndex(upper).style
//
//    // 패딩·높이 등 연속적인 수치 속성은 lerp로 부드럽게 보간
//    let top = lerp(s0.topPadding, s1.topPadding, t)
//    let bottom = lerp(s0.bottomPadding, s1.bottomPadding, t)
//    let side = lerp(s0.sidePadding, s1.sidePadding, t)
//    let lineH = lerp(s0.oneLineHeight, s1.oneLineHeight, t)
//
//    // 폰트는 보간이 불가능하므로 가까운 쪽(50% 기준)의 폰트를 선택
//    let fontName = (t < 0.5) ? s0.fontName : s1.fontName
//
//    return CardTypeStyle(
//        topPadding: top,
//        bottomPadding: bottom,
//        sidePadding: side,
//        oneLineHeight: lineH,
//        fontName: fontName,
//        depth: clamped
//    )
//}
