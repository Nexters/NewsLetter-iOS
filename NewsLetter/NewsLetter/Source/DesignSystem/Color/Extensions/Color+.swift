//
//  Color+.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double((hex >> 0) & 0xff) / 255,
            opacity: opacity
        )
    }
}
