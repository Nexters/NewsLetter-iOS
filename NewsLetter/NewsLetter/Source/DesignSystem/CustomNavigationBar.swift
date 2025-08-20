//
//  CustomNavigationBar.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/14/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image("arrow_left_icon")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(6)
            }
            Spacer()
        }
        .frame(height: 44)
        .padding(.leading, 6)
    }
}

#Preview {
    CustomNavigationBar()
}
