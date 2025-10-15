//
//  ShapeStyle+.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static var accentColor: AccentColor {
        AccentColor()
    }
    
    static var semanticColor: SemanticColor {
        SemanticColor()
    }
}
