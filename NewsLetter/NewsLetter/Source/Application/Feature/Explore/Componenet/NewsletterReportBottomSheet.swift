//
//  NewsletterReportBottomSheet.swift
//  NewsLetter
//

import SwiftUI

struct NewsletterReportBottomSheet: View {

    @Binding var isPresented:  Bool

    @State private var newsletterURL: String = ""
    @State private var blogURL: String = ""
    @State private var memo: String = ""
    @State private var selectedCategories: Set<Int> = []

    private let categories: [(label: String, icon: String)] = [
        ("AND",    "android_icon"),
        ("iOS",    "ios_icon"),
        ("FE",     "fe_icon"),
        ("BE",     "be_icon"),
        ("DevOps", "devops_icon")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("추가되었으면 하는\n뉴스레터나 블로그가 있나요?")
                        .font(.head20_bold)
                        .foregroundStyle(.semanticColor.text_primary)

                    Text("신규 뉴스레터를 제보해주세요")
                        .font(.body14_regular)
                        .foregroundStyle(.semanticColor.text_secondary)
                }
                .padding(.top, 12)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(.semanticColor.fill_secondary)
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .fontWeight(.semibold)
                            .foregroundStyle(.semanticColor.icon_strong)
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 0) {

                inputField(
                    label: "이름",
                    placeholder: "이름",
                    text: $newsletterURL
                )

                inputField(
                    label: "주소",
                    placeholder: "URL",
                    text: $blogURL
                )

                categorySection

                inputField(
                    label: "언어",
                    placeholder: "개발 언어",
                    text: $memo
                )
            }
            .padding(.top, 24)

            Spacer()

            Button {
                isPresented = false
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.semanticColor.button_primary)
                    .frame(height: 56)
                    .overlay {
                        Text("제출")
                            .font(.body16_bold)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func inputField(
        label: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.body14_semiBold)
                .foregroundStyle(.semanticColor.text_secondary)

            HStack {
                TextField("", text: text)
                    .font(.body16_regular)
                    .foregroundStyle(.semanticColor.text_secondary)
                    .placeholder(when: text.wrappedValue.isEmpty) {
                        Text(placeholder)
                            .font(.body16_regular)
                            .foregroundStyle(.semanticColor.text_tertiary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
            }
            .padding(8)
            .frame(height: 56)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.semanticColor.border_primary, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("직군")
                .font(.body14_semiBold)
                .foregroundStyle(.semanticColor.text_secondary)
                .padding(.top, 8)

            ChipFlowLayout(spacing: 8) {
                ForEach(categories.indices, id: \.self) { index in
                    let category = categories[index]
                    let isSelected = selectedCategories.contains(index)

                    Button {
                        if isSelected {
                            selectedCategories.remove(index)
                        } else {
                            selectedCategories.insert(index)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(category.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            Text(category.label)
                                .font(.body15_medium)
                                .foregroundStyle(.semanticColor.text_primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isSelected ? .semanticColor.text_primary : .semanticColor.border_primary,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

#Preview {
    NewsletterReportBottomSheet(isPresented: .constant(true))
}
