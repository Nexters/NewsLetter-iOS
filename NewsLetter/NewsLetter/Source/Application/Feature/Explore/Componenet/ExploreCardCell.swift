//
//  ExploreCardCell.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import SwiftUI

struct ExploreCardCell: View {
    let data: ExploreCard
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data.title)
                .font(.body15_bold)
                .foregroundStyle(.semanticColor.text_strong)
            Spacer()
            HStack {
                Text(data.topKeyword)
                    .font(.body13_medium)
                    .foregroundStyle(.semanticColor.icon_strong)
                    .opacity(0.5)
                Rectangle()
                    .frame(width: 1, height: 14)
                    .foregroundStyle(.semanticColor.icon_strong)
                    .opacity(0.1)
                Text(data.newsletterName)
                    .font(.body13_medium)
                    .foregroundStyle(.semanticColor.icon_strong)
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color)
        .cornerRadius(16, corners: .allCorners)
    }
}

#Preview {
    ExploreCardCell(data: .stub(), color: .gray)
}
