//
//  TypoStyle.swift
//  NewsLetter
//
//  Created by 이조은 on 7/18/25.
//

import SwiftUI

public enum TypoStyle {
    case head28_bold, head28_semiBold, head28_medium, head28_regular
    case head26_bold, head26_semiBold, head26_medium, head26_regular
    case head24_bold, head24_semiBold, head24_medium, head24_regular
    case head22_bold, head22_semiBold, head22_medium, head22_regular
    case head20_bold, head20_semiBold, head20_medium, head20_regular

    case body18_bold, body18_semiBold, body18_medium, body18_regular
    case body16_bold, body16_semiBold, body16_medium, body16_regular
    case body15_bold, body15_semiBold, body15_medium, body15_regular
    case body14_bold, body14_semiBold, body14_medium, body14_regular
    case body13_bold, body13_semiBold, body13_medium, body13_regular

    case caption12_bold, caption12_semiBold, caption12_medium, caption12_regular
    case caption11_bold, caption11_semiBold, caption11_medium, caption11_regular

    var font: Font {
        switch self {
        case .head28_bold: return Font.custom("Pretendard-Bold", size: 28)
        case .head28_semiBold: return Font.custom("Pretendard-SemiBold", size: 28)
        case .head28_medium: return Font.custom("Pretendard-Medium", size: 28)
        case .head28_regular: return Font.custom("Pretendard-Regular", size: 28)

        case .head26_bold: return Font.custom("Pretendard-Bold", size: 26)
        case .head26_semiBold: return Font.custom("Pretendard-SemiBold", size: 26)
        case .head26_medium: return Font.custom("Pretendard-Medium", size: 26)
        case .head26_regular: return Font.custom("Pretendard-Regular", size: 26)

        case .head24_bold: return Font.custom("Pretendard-Bold", size: 24)
        case .head24_semiBold: return Font.custom("Pretendard-SemiBold", size: 24)
        case .head24_medium: return Font.custom("Pretendard-Medium", size: 24)
        case .head24_regular: return Font.custom("Pretendard-Regular", size: 24)

        case .head22_bold: return Font.custom("Pretendard-Bold", size: 22)
        case .head22_semiBold: return Font.custom("Pretendard-SemiBold", size: 22)
        case .head22_medium: return Font.custom("Pretendard-Medium", size: 22)
        case .head22_regular: return Font.custom("Pretendard-Regular", size: 22)

        case .head20_bold: return Font.custom("Pretendard-Bold", size: 20)
        case .head20_semiBold: return Font.custom("Pretendard-SemiBold", size: 20)
        case .head20_medium: return Font.custom("Pretendard-Medium", size: 20)
        case .head20_regular: return Font.custom("Pretendard-Regular", size: 20)

        case .body18_bold: return Font.custom("Pretendard-Bold", size: 18)
        case .body18_semiBold: return Font.custom("Pretendard-SemiBold", size: 18)
        case .body18_medium: return Font.custom("Pretendard-Medium", size: 18)
        case .body18_regular: return Font.custom("Pretendard-Regular", size: 18)

        case .body16_bold: return Font.custom("Pretendard-Bold", size: 16)
        case .body16_semiBold: return Font.custom("Pretendard-SemiBold", size: 16)
        case .body16_medium: return Font.custom("Pretendard-Medium", size: 16)
        case .body16_regular: return Font.custom("Pretendard-Regular", size: 16)

        case .body15_bold: return Font.custom("Pretendard-Bold", size: 15)
        case .body15_semiBold: return Font.custom("Pretendard-SemiBold", size: 15)
        case .body15_medium: return Font.custom("Pretendard-Medium", size: 15)
        case .body15_regular: return Font.custom("Pretendard-Regular", size: 15)

        case .body14_bold: return Font.custom("Pretendard-Bold", size: 14)
        case .body14_semiBold: return Font.custom("Pretendard-SemiBold", size: 14)
        case .body14_medium: return Font.custom("Pretendard-Medium", size: 14)
        case .body14_regular: return Font.custom("Pretendard-Regular", size: 14)

        case .body13_bold: return Font.custom("Pretendard-Bold", size: 13)
        case .body13_semiBold: return Font.custom("Pretendard-SemiBold", size: 13)
        case .body13_medium: return Font.custom("Pretendard-Medium", size: 13)
        case .body13_regular: return Font.custom("Pretendard-Regular", size: 13)

        case .caption12_bold: return Font.custom("Pretendard-Bold", size: 12)
        case .caption12_semiBold: return Font.custom("Pretendard-SemiBold", size: 12)
        case .caption12_medium: return Font.custom("Pretendard-Medium", size: 12)
        case .caption12_regular: return Font.custom("Pretendard-Regular", size: 12)

        case .caption11_bold: return Font.custom("Pretendard-Bold", size: 11)
        case .caption11_semiBold: return Font.custom("Pretendard-SemiBold", size: 11)
        case .caption11_medium: return Font.custom("Pretendard-Medium", size: 11)
        case .caption11_regular: return Font.custom("Pretendard-Regular", size: 11)
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .head28_bold, .head28_semiBold, .head28_medium, .head28_regular: return 38
        case .head26_bold, .head26_semiBold, .head26_medium, .head26_regular: return 35
        case .head24_bold, .head24_semiBold, .head24_medium, .head24_regular: return 32
        case .head22_bold, .head22_semiBold, .head22_medium, .head22_regular: return 31
        case .head20_bold, .head20_semiBold, .head20_medium, .head20_regular: return 28

        case .body18_bold, .body18_semiBold, .body18_medium, .body18_regular: return 26
        case .body16_bold, .body16_semiBold, .body16_medium, .body16_regular: return 24
        case .body15_bold, .body15_semiBold, .body15_medium, .body15_regular: return 22
        case .body14_bold, .body14_semiBold, .body14_medium, .body14_regular: return 20
        case .body13_bold, .body13_semiBold, .body13_medium, .body13_regular: return 18

        case .caption12_bold, .caption12_semiBold, .caption12_medium, .caption12_regular: return 16
        case .caption11_bold, .caption11_semiBold, .caption11_medium, .caption11_regular: return 14
        }
    }

    // lineHeight를 직접 계산하기 위해서 UIFont를 가져와서 반환
    // UIFont가 반환되어야 해당 폰트의 height을 계산할 수 있기 때문에
    var uiFont: UIFont {
        switch self {
        case .head28_bold: return UIFont(name: "Pretendard-Bold", size: 28)!
        case .head28_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 28)!
        case .head28_medium: return UIFont(name: "Pretendard-Medium", size: 28)!
        case .head28_regular: return UIFont(name: "Pretendard-Regular", size: 28)!

        case .head26_bold: return UIFont(name: "Pretendard-Bold", size: 26)!
        case .head26_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 26)!
        case .head26_medium: return UIFont(name: "Pretendard-Medium", size: 26)!
        case .head26_regular: return UIFont(name: "Pretendard-Regular", size: 26)!

        case .head24_bold: return UIFont(name: "Pretendard-Bold", size: 24)!
        case .head24_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 24)!
        case .head24_medium: return UIFont(name: "Pretendard-Medium", size: 24)!
        case .head24_regular: return UIFont(name: "Pretendard-Regular", size: 24)!

        case .head22_bold: return UIFont(name: "Pretendard-Bold", size: 22)!
        case .head22_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 22)!
        case .head22_medium: return UIFont(name: "Pretendard-Medium", size: 22)!
        case .head22_regular: return UIFont(name: "Pretendard-Regular", size: 22)!

        case .head20_bold: return UIFont(name: "Pretendard-Bold", size: 20)!
        case .head20_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 20)!
        case .head20_medium: return UIFont(name: "Pretendard-Medium", size: 20)!
        case .head20_regular: return UIFont(name: "Pretendard-Regular", size: 20)!

        case .body18_bold: return UIFont(name: "Pretendard-Bold", size: 18)!
        case .body18_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 18)!
        case .body18_medium: return UIFont(name: "Pretendard-Medium", size: 18)!
        case .body18_regular: return UIFont(name: "Pretendard-Regular", size: 18)!

        case .body16_bold: return UIFont(name: "Pretendard-Bold", size: 16)!
        case .body16_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 16)!
        case .body16_medium: return UIFont(name: "Pretendard-Medium", size: 16)!
        case .body16_regular: return UIFont(name: "Pretendard-Regular", size: 16)!

        case .body15_bold: return UIFont(name: "Pretendard-Bold", size: 15)!
        case .body15_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 15)!
        case .body15_medium: return UIFont(name: "Pretendard-Medium", size: 15)!
        case .body15_regular: return UIFont(name: "Pretendard-Regular", size: 15)!

        case .body14_bold: return UIFont(name: "Pretendard-Bold", size: 14)!
        case .body14_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 14)!
        case .body14_medium: return UIFont(name: "Pretendard-Medium", size: 14)!
        case .body14_regular: return UIFont(name: "Pretendard-Regular", size: 14)!

        case .body13_bold: return UIFont(name: "Pretendard-Bold", size: 13)!
        case .body13_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 13)!
        case .body13_medium: return UIFont(name: "Pretendard-Medium", size: 13)!
        case .body13_regular: return UIFont(name: "Pretendard-Regular", size: 13)!

        case .caption12_bold: return UIFont(name: "Pretendard-Bold", size: 12)!
        case .caption12_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 12)!
        case .caption12_medium: return UIFont(name: "Pretendard-Medium", size: 12)!
        case .caption12_regular: return UIFont(name: "Pretendard-Regular", size: 12)!

        case .caption11_bold: return UIFont(name: "Pretendard-Bold", size: 11)!
        case .caption11_semiBold: return UIFont(name: "Pretendard-SemiBold", size: 11)!
        case .caption11_medium: return UIFont(name: "Pretendard-Medium", size: 11)!
        case .caption11_regular: return UIFont(name: "Pretendard-Regular", size: 11)!
        }
    }
}

extension View {
    func typo(_ style: TypoStyle) -> some View {
        let systemLineHeight = style.uiFont.lineHeight
        let spacing = (style.lineHeight - systemLineHeight) / 2

        return self
            .font(style.font)
            .lineSpacing(style.lineHeight - systemLineHeight)
            .padding(.vertical, spacing)
    }
}
