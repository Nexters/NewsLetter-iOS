//
//  DeviceSize.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/28/25.
//

import Foundation
import UIKit

enum Device {
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
    
    static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets
        } else {
            return .zero
        }
    }
}
