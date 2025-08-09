//
//  View+.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/28/25.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func toastMessage(isPresented: Binding<Bool>, text: String, bottomPadding: CGFloat) -> some View {
        self.modifier(ToastMessage(isPresented: isPresented, text: text, bottomPadding: bottomPadding))
    }
    
    func fontRangeLimited() -> some View {
        self.dynamicTypeSize(.small ... .xxxLarge)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ToastMessage: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    let bottomPadding: CGFloat
    
    init(isPresented: Binding<Bool>, text: String, bottomPadding: CGFloat) {
        _isPresented = isPresented
        self.text = text
        self.bottomPadding = bottomPadding
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            
            Text(text)
                .font(.body15_medium)
                .foregroundColor(.white)
                .padding(.vertical, 13)
                .frame(width: Device.width - 16)
                .background(
                    Color.init(hex: 0x242729)
                )
                .cornerRadius(6, corners: .allCorners)
                .opacity(isPresented ? 1 : 0)
                .offset(y: isPresented ? 0 : 20)
                .animation(.bouncy, value: isPresented)
                .padding(.bottom, bottomPadding)
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    isPresented = false
                }
            }
        }
    }
}
