//
//  JobDetailBottomSheet.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/29/25.
//

import SwiftUI

import FirebaseAnalytics

struct JobDetailBottomSheet: View {
    @State private var selectedJobCategory: Set<Int> = []
    @State private var selectedCareer: Int?

    private var isEnabledButton: Bool {
        selectedCareer != nil && selectedJobCategory.isEmpty == false
    }

    let confirmHandler: (Set<Int>, Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("정보를 등록하면\n매일 뉴스레터를 추천해 드려요")
                .font(.head22_bold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 0) {
                Text("관심직군")
                    .font(.body14_semiBold)
                    .padding(.vertical, 12)

                LeftAlignedCollectionView<JobCell>(
                    data: .constant([
                        CellTypeData.init(
                            text: "AND",
                            imageURL: "android_icon"
                        ),
                        CellTypeData.init(
                            text: "iOS",
                            imageURL: "ios_icon"
                        ),
                        CellTypeData.init(
                            text: "FE",
                            imageURL: "fe_icon"
                        ),
                        CellTypeData.init(
                            text: "BE",
                            imageURL: "be_icon"
                        )
                    ]),
                    selectedIndex: .constant(nil),
                    selectedIndices: $selectedJobCategory
                )
                .frame(height: 38)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 0) {
                Text("경력")
                    .font(.body14_semiBold)
                    .padding(.vertical, 12)

                LeftAlignedCollectionView<CareerCell>(
                    data: .constant([
                        CellTypeData.init(text: "대학생 · 취준생"),
                        CellTypeData.init(text: "1 ~ 3년차"),
                        CellTypeData.init(text: "4 ~ 7년차"),
                        CellTypeData.init(text: "8 ~ 10년차"),
                        CellTypeData.init(text: "10년차 이상")
                    ]),
                    selectedIndex: $selectedCareer,
                    selectedIndices: .constant(.init())
                )
                .frame(height: 84)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)

            Button {
                UserActionHistory.isAlreadyInputJobDetail = true
                confirmHandler(selectedJobCategory, selectedCareer ?? 0)

                let preferences = selectedJobCategory.map { Preference.allCases[$0].rawValue }

                guard let selectedCareer = selectedCareer else {
                    print("❌ 경력 정보가 선택되지 않았습니다.")
                    return
                }
                let workingExperience = WorkingExperience.allCases[selectedCareer].rawValue

                if UserActionHistory.selectedCareer != [preferences, [workingExperience]] {
                    UserActionHistory.isChangedCareer = true
                    UserActionHistory.selectedCareer = [preferences, [workingExperience]]
                }

                let dataDictionary: [String: Any] = [
                    "job_group": preferences,
                    "career_level": workingExperience
                ]

                let dataString = (try? JSONSerialization.data(withJSONObject: dataDictionary))
                    .flatMap { String(data: $0, encoding: .utf8) }

                Analytics.logEvent("bottom_sheet_custom_click", parameters: [
                    "category": "click",
                    "navigation": "bottom_sheet_custom",
                    "object_section": "bottom_sheet",
                    "object_type": "button",
                    "user_properties": dataString ?? ""
                ])
            } label: {
                RoundedRectangle(cornerRadius: 100)
                    .frame(height: 56)
                    .foregroundStyle(isEnabledButton ? .semanticColor.fill_primaryInversion : .semanticColor.fill_disabled)
                    .padding(.horizontal, 16)
                    .overlay {
                        Text("맞춤 뉴스레터 보기")
                            .font(.body16_semiBold)
                            .foregroundStyle(isEnabledButton ? .semanticColor.text_strongInverse : .semanticColor.text_disabled)
                    }
            }
            .padding(.bottom, 16)
            .disabled(!isEnabledButton)
        }
        .onAppear() {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [
                                AnalyticsParameterScreenName: "bottom_sheet_custom"
                               ])
        }
    }
}

#Preview {
    JobDetailBottomSheet { _, _ in
    }
    .debug()
}
