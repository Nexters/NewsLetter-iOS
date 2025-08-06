//
//  ColorPalette+.swift
//  NewsLetter
//
//  Created by 이조은 on 8/6/25.
//

import SwiftUI

enum ColorPaletteName: String, Codable, CaseIterable {
    case pointBlue200, pointBlue300, pointBlue400
    case pointOrange300, pointOrange400, pointOrange500
    case pointPink200, pointPink300, pointPink400
    case pointPurple150, pointPurple200, pointPurple300
    case pointGreen200, pointGreen300, pointGreen400
    case pointLemonYellow200, pointLemonYellow300, pointLemonYellow400

    var color: Color {
        switch self {
        case .pointBlue200: return ColorPalette.pointBlue200
        case .pointBlue300: return ColorPalette.pointBlue300
        case .pointBlue400: return ColorPalette.pointBlue400

        case .pointOrange300: return ColorPalette.pointOrange300
        case .pointOrange400: return ColorPalette.pointOrange400
        case .pointOrange500: return ColorPalette.pointOrange500

        case .pointPink200: return ColorPalette.pointPink200
        case .pointPink300: return ColorPalette.pointPink300
        case .pointPink400: return ColorPalette.pointPink400

        case .pointPurple150: return ColorPalette.pointPurple150
        case .pointPurple200: return ColorPalette.pointPurple200
        case .pointPurple300: return ColorPalette.pointPurple300

        case .pointGreen200: return ColorPalette.pointGreen200
        case .pointGreen300: return ColorPalette.pointGreen300
        case .pointGreen400: return ColorPalette.pointGreen400

        case .pointLemonYellow200: return ColorPalette.pointLemonYellow200
        case .pointLemonYellow300: return ColorPalette.pointLemonYellow300
        case .pointLemonYellow400: return ColorPalette.pointLemonYellow400
        }
    }

    static func from(color: Color) -> ColorPaletteName? {
        return Self.allCases.first(where: { $0.color.description == color.description })
    }
}
