//
//  ExploreCategoryFilterView.swift
//  NewsLetter
//

import SwiftUI

private struct ExploreCategoryChip: Identifiable {
    let id: Preference?
    let title: String
    let iconName: String?
}

private let exploreCategoryChips: [ExploreCategoryChip] = [
    ExploreCategoryChip(id: nil, title: "전체", iconName: nil),
    ExploreCategoryChip(id: .android, title: "AND", iconName: "android_icon"),
    ExploreCategoryChip(id: .iOS, title: "iOS", iconName: "ios_icon"),
    ExploreCategoryChip(id: .frontend, title: "FE", iconName: "fe_icon"),
    ExploreCategoryChip(id: .backend, title: "BE", iconName: "be_icon"),
    ExploreCategoryChip(id: .devops, title: "DevOps", iconName: "devops_icon"),
]

struct ExploreCategoryFilterView: View {
    let selectedCategories: Set<Preference>
    let tapHandler: (Preference?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(exploreCategoryChips) { chip in
                    chipView(chip)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func chipView(_ chip: ExploreCategoryChip) -> some View {
        let isSelected = chip.id == nil
            ? selectedCategories.isEmpty
            : selectedCategories.contains(chip.id!)

        Button {
            tapHandler(chip.id)
        } label: {
            HStack(spacing: 4) {
                if let iconName = chip.iconName {
                    Image(iconName)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                Text(chip.title)
                    .font(isSelected ? .caption12_semiBold : .caption12_regular)
                    .foregroundStyle(isSelected ? .semanticColor.text_primary : .semanticColor.text_strongInverse)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(isSelected ? .semanticColor.background_base : Color.clear)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? .semanticColor.border_primary : .semanticColor.border_active,
                        lineWidth: isSelected ? 1 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExploreCategoryFilterView(selectedCategories: [.frontend], tapHandler: { _ in })
        .background(Color.black)
}
