//
//  CardType.swift
//  NewsLetter
//
//  Created by 이조은 on 7/26/25.
//
import SwiftUI

enum CardType {
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

    var oneLine: Int {
        switch self {
        case .one:   return 15
        case .two:   return 17
        case .three: return 18
        case .four:  return 19
        case .five:  return 19
        case .six:   return 21
        }
    }
}
