//
//  CardView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/19/25.
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
    
    var backgroundColor: Color {
        switch self {
        case .one: return .accentColor.purple
        case .two: return .accentColor.orange
        case .three: return .accentColor.skyblue
        case .four: return .accentColor.lemonyellow
        case .five: return .accentColor.pink
        case .six: return .accentColor.green
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

struct CardView: View {
    let cardType: CardType
    let title: String
    let category: String
    let source: String
    
    @State private var contentHeight: CGFloat = 0
    
    // 제목 최대 28글자까지
    var trimmedTitle: String {
        String(title.prefix(28))
    }
    
    // title이 몇 줄이 되는지 계산
    var titleLineCount: Int {
        let lines = Double(title.count) / Double(cardType.oneLine)
        return Int(ceil(lines))
    }
    
    // 크기가 작은 3종류는 제목이 2줄이면 카테고리랑 출처가 없어야 한다.
    var hideCategoryAndSource: Bool {
        switch cardType {
        case .one, .two, .three:
            return titleLineCount >= 2
        default:
            return false
        }
    }
    
    @State private var vStackHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(cardType.backgroundColor)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(trimmedTitle)
                    .font(cardType.fontName)
                    .foregroundStyle(.semanticColor.text_strong)
                    .padding(.top, hideCategoryAndSource ? 16 : cardType.topPadding)
                    .padding(.bottom, hideCategoryAndSource ? cardType.bottomPadding : 4)
                
                if !hideCategoryAndSource {
                    HStack(spacing: 6) {
                        Text(category)
                            .font(.body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))
                        
                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundStyle(ColorPalette.black.opacity(0.1))
                        
                        Text(source)
                            .font(.body13_medium)
                            .foregroundStyle(.semanticColor.text_strong.opacity(0.5))
                    }
                    .padding(.bottom, cardType.bottomPadding)
                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom, 0)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            self.vStackHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size.height) { newValue in
                            self.vStackHeight = newValue
                        }
                }
            )
        }
        .padding([.leading, .trailing], cardType.sidePadding)
        .frame(height: vStackHeight == 0 ? nil : vStackHeight + 30)
    }
}

#Preview {
    VStack(spacing:-30) {
        CardView(cardType: .one, title: "메가커피 컵빙수의 품절 대란", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .two, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .three, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .four, title: "직장인이라면 알아야 할 주 4일제의 모든 것", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .five, title: "이재명 정부 부동산 규제, 더 큰 게 온다? 전 대통령, 구속영장", category: "Kotlin", source: "안드로이드 위클리")
        CardView(cardType: .six, title: "재구속 앞둔 윤석열 전 대통령, 구속영장은?", category: "Kotlin", source: "안드로이드 위클리")
    }
}
