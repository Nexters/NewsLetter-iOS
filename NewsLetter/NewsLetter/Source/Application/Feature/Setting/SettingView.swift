//
//  SettingView.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/13/25.
//

import SwiftUI

import ComposableArchitecture

struct SettingView: View {
    @Bindable var store: StoreOf<SettingReducer>
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar()
                .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 24) {
                sectionTitle(title: "내정보")
                navigationRow(title: "맞춤 설정") { store.send(.setIsPresentJobDetailBottomSheet(true)) }
                navigationRow(title: "알림") { } // TODO: 정책 미정.
                
                Divider()
                
                sectionTitle(title: "버전정보")
                normalRow(title: "현재버전", value: "\(AppInfo.appVersion)(\(AppInfo.buildNumber))")
                
                Divider()
                
                sectionTitle(title: "고객지원")
                normalRow(title: "문의하기", value: "newsletter.feeding@gmail.com")
                
                Divider()
                
                sectionTitle(title: "약관 및 정책")
                navigationRow(title: "서비스 이용약관") { store.send(.setNavigateToTermsOfService(true)) }
                navigationRow(title: "개인정보 취급 방침") { store.send(.setNavigateToPrivacyPolicy(true)) }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .draggableBottomSheet(
            isShow: $store.isPresentJobDetailBottomSheet,
            dismissHandler: { UserActionHistory.deniedDateWhenInputJobDetail = Date() }
        ) {
            JobDetailBottomSheet { selectedJobCategory, selectedCareer in
                jobDetailBottomSheetConfirmHandler(
                    selectedJobCategory: selectedJobCategory,
                    selectedCareer: selectedCareer
                )
                store.send(.setIsPresentJobDetailBottomSheet(false))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toastMessage(
            isPresented: $store.isPresentToastMessage,
            text: "직군정보 등록이 완료되었어요.",
            bottomPadding: 0
        )
        .toolbar(.hidden)
        .navigationDestination(isPresented: $store.navigateToPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .navigationDestination(isPresented: $store.navigateToTermsOfService) {
            TermsOfServiceView()
        }
    }
    
    private func jobDetailBottomSheetConfirmHandler(
        selectedJobCategory: Set<Int>,
        selectedCareer: Int
    ) {
        let preferences = selectedJobCategory.map { Preference.allCases[$0] }
        let workingExperience = WorkingExperience.allCases[selectedCareer]
        let requestDTO = UserUpdateRequestDTO(
            preferences: preferences,
            workingExperience: workingExperience
        )
        store.send(.updateUser(requestDTO))
        store.send(.setIsPresentJobDetailBottomSheet(false))
    }
    
    @ViewBuilder
    private func sectionTitle(title: String) -> some View {
        Text(title)
            .font(.body16_medium)
            .foregroundColor(Color(hex: 0x727484))
    }
    
    @ViewBuilder
    private func navigationRow(title: String, _ tapHandler: @escaping () -> Void) -> some View {
        Button {
            tapHandler()
        } label: {
            HStack {
                Text(title)
                    .font(.body18_medium)
                    .foregroundColor(Color(hex: 0x404249))
                Spacer()
                Image("right_arrow_icon")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    @ViewBuilder
    private func normalRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body18_medium)
                .foregroundColor(Color(hex: 0x404249))
            Spacer()
            
            if value.contains("@"),
               let url = URL(string: "mailto:\(value)") {
                Link(value, destination: url)
                    .font(.body16_regular)
                    .foregroundColor(.blue)
            } else {
                Text(value)
                    .font(.body16_regular)
                    .foregroundColor(Color(hex: 0x404249))
            }
        }
    }
}

#Preview {
    SettingView(
        store: Store(initialState: SettingReducer.State()) {
            SettingReducer()
        }
    )
}
