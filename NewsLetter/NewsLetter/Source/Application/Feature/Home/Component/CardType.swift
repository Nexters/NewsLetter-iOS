//
//  CardType.swift
//  NewsLetter
//
//  Created by 이조은 on 7/26/25.
//
import SwiftUI

public enum CardType {
    case one, two, three, four, five, six

    var topPadding: CGFloat {
        switch self {
        case .one: return 16
        case .two, .three, .four, .five, .six: return 20
        }
    }

    var bottomPadding: CGFloat {
        switch self {
        case .one: return 12
        case .two, .three, .four, .five, .six: return 16
        }
    }

    var sidePadding: CGFloat {
        switch self {
        case .one: return 80
        case .two: return 64
        case .three: return 48
        case .four: return 32
        case .five: return 16
        case .six: return 0
        }
    }

    var fontName: FontStyle {
        switch self {
        case .one: return .body13_bold
        case .two: return .body14_bold
        case .three: return .body15_bold
        case .four: return .body16_bold
        case .five, .six: return .body18_bold
        }
    }

    var fontNameSE: FontStyle {
        switch self {
        case .one: return .caption12_bold
        case .two: return .body13_bold
        case .three: return .body14_bold
        case .four: return .body15_bold
        case .five, .six: return .body16_bold
        }
    }

    var oneLineHeight: Int {
        switch self {
        case .one:   return 19
        case .two:   return 21
        case .three: return 23
        case .four:  return 25
        case .five:  return 27
        case .six:   return 27
        }
    }

    var visualScale: CGFloat {
        switch self {
        case .one:   return 0.86
        case .two:   return 0.90
        case .three: return 0.93
        case .four:  return 0.96
        case .five:  return 0.98
        case .six:   return 1.00
        }
    }
}
