//
//  JobDetailBottomSheet.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/29/25.
//

import SwiftUI

import FirebaseAnalytics

struct JobDetailBottomSheet: View {
    static let changeConfirmationMessage = "관심 직군 변경은 **계정당 한 번만 가능**합니다. 변경 후에는 다른 직군으로 수정할 수 없습니다."

    @State private var selectedJobCategory: Set<Int>
    @State private var selectedCareer: Int?

    /// 서버에서 내려준, 계정당 1회 허용되는 직군 변경을 이미 사용했는지 여부. true면 이미 변경 이력이 있어 더 이상 변경할 수 없습니다.
    let isCategoryChanged: Bool
    /// 진입 시점에 이미 등록된 직군 정보가 있었는지 여부. 최초 등록(정보가 없던 상태)에서는 확인 다이얼로그 없이 바로 반영하고,
    /// 기존 정보를 수정하는 경우에만 확인 다이얼로그를 거칩니다.
    private let hasExistingSelection: Bool

    private var isEnabledButton: Bool {
        selectedCareer != nil && selectedJobCategory.isEmpty == false && isCategoryChanged == false
    }

    let confirmHandler: (Set<Int>, Int) -> Void
    /// 바텀시트 영역에 갇히지 않고 화면 전체 기준으로 확인 다이얼로그를 띄울 수 있도록,
    /// 다이얼로그 노출 자체는 상위 화면(호출부)에 위임합니다. 사용자가 다이얼로그에서 확정하면 전달받은 `commit`을 호출해주세요.
    let requestChangeConfirmation: (_ commit: @escaping () -> Void) -> Void

    init(
        initialSelectedJobCategory: Set<Int> = [],
        initialSelectedCareer: Int? = nil,
        isCategoryChanged: Bool = false,
        requestChangeConfirmation: @escaping (_ commit: @escaping () -> Void) -> Void = { commit in commit() },
        confirmHandler: @escaping (Set<Int>, Int) -> Void
    ) {
        _selectedJobCategory = State(initialValue: initialSelectedJobCategory)
        _selectedCareer = State(initialValue: initialSelectedCareer)
        self.isCategoryChanged = isCategoryChanged
        self.hasExistingSelection = initialSelectedJobCategory.isEmpty == false || initialSelectedCareer != nil
        self.requestChangeConfirmation = requestChangeConfirmation
        self.confirmHandler = confirmHandler
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("정보를 등록하면\n매일 뉴스레터를 추천해 드려요")
                .font(.head22_bold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("* 계정당 한 번의 직군 변경만 허용하고 있어요.")
                .font(.body13_medium)
                .foregroundStyle(.semanticColor.text_tertiary)
                .padding(.top, 4)
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
                        ),
                        CellTypeData.init(
                            text: "DevOps",
                            imageURL: "devops_icon"
                        )
                    ]),
                    selectedIndex: .constant(nil),
                    selectedIndices: $selectedJobCategory
                )
                .frame(height: 84)
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
                if hasExistingSelection {
                    requestChangeConfirmation { performConfirm() }
                } else {
                    performConfirm()
                }
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
            GA.pageview_bottom_sheet_custom()
        }
    }

    private func performConfirm() {
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
        GA.click_bottom_sheet_custom(userData: dataDictionary)
    }
}

#Preview {
    JobDetailBottomSheet { _, _ in
    }
    .debug()
}
