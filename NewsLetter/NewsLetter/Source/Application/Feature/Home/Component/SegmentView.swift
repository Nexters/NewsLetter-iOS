//
//  SegmentView.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/20/25.
//

import SwiftUI

struct SegmentView: View {
    enum SegmentType: CaseIterable {
        case recommend
        case explore
        
        var title: String {
            switch self {
            case .recommend: return "추천"
            case .explore:   return "탐색"
            }
        }
    }
    
    @Binding var selectedSegment: SegmentType
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(SegmentType.allCases, id: \.self) { segment in
                Button {
                    selectedSegment = segment
                } label: {
                    segmentLabel(for: segment)
                }
            }
        }
    }
    
    @ViewBuilder
    private func segmentLabel(for segment: SegmentType) -> some View {
        let isSelected = (selectedSegment == segment)
        let selectedTitleColor: Color = selectedSegment == .recommend ?
            .semanticColor.text_strong : .semanticColor.text_strongInverse
        let selectedUnderBarColor: Color = selectedSegment == .recommend ?
            .semanticColor.icon_strong : .semanticColor.icon_strongInverse
        
        VStack(spacing: 1) {
            Text(segment.title)
                .font(isSelected ? .body15_bold : .body15_regular)
                .foregroundColor(isSelected ? selectedTitleColor : .semanticColor.text_tertiary)
            RoundedRectangle(cornerRadius: 1)
                .frame(width: 18, height: 2)
                .foregroundStyle(selectedUnderBarColor)
                .opacity(isSelected ? 1 : 0)
        }
    }
}

#Preview {
    SegmentView(selectedSegment: .constant(.recommend))
}
