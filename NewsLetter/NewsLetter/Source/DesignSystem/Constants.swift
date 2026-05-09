//
//  Constants.swift
//  NewsLetter
//
//  Created by 이원빈 on 9/14/25.
//

import Foundation
import SwiftUI

/// ZIndex 상수 정의
enum Z {
    static let cardDefault: Double = 0
    static let cardElevated: Double = 10
    static let carouselModal: Double = 20
    static let bottomSheet: Double = 50
}

typealias COLORSET = (main: Color, sub: Color)
let COLORSET_LIST: [COLORSET] = [
    (ColorPalette.gray400, ColorPalette.gray100), // FIXME: TrandingCard 색상지정 필요
    (ColorPalette.pointPurple200, ColorPalette.pointPurpleTextPrimary),
    (ColorPalette.pointOrange400, ColorPalette.pointOrangeTextPrimary),
    (ColorPalette.pointBlue300, ColorPalette.pointBlueTextPrimary),
    (ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellowTextPrimary),
    (ColorPalette.pointPink300, ColorPalette.pointPinkTextPrimary),
    (ColorPalette.pointGreen300, ColorPalette.pointGreenTextPrimary),
]
