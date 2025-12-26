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
                navigationRow(title: "알림") { store.send(.setIsPresentNotificationPermissionBottomSheet(true)) }
                
                Divider()
                
                sectionTitle(title: "버전정보")
                normalRow(
                    title: "현재버전",
                    value: "\(AppInfo.appVersion)(\(AppInfo.buildNumber))",
                    tapHandler: { store.send(.versionRowTapped) }
                )
                
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
        .draggableBottomSheet(
            isShow: $store.isPresentNotificationPermissionBottomSheet,
            dismissHandler: { UserActionHistory.deniedDateWhenSetNotification = Date() }
        ) {
            NotificationPermissionBottomSheet(
                isPresented: $store.isPresentNotificationPermissionBottomSheet,
                successHandler: {
//                    store.send(.registerUser) /// 앱 처음 진입 시 registerUser 를 하므로, 기존 요청 주석처리. 추후 제거
                    store.send(.setIsPresentNotiToastMessage(true))
                }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .toastMessage(
            isPresented: $store.isPresentNotiToastMessage,
            text: "뉴스레터 알림이 신청되었어요",
            bottomPadding: 0
        )
        .toastMessageWithButton(
            isPresented: $store.isPresentTokenToast,
            text: store.tokenToastText,
            buttonTitle: "복사하기",
            bottomPadding: 0
        ) {
            guard store.isTokenCopyable else { return }
            UIPasteboard.general.string = store.tokenToastText
        }
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
    private func normalRow(
        title: String,
        value: String,
        tapHandler: (() -> Void)? = nil
    ) -> some View {
        let content = HStack {
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
        
        if let tapHandler = tapHandler {
            content
                .contentShape(Rectangle())
                .onTapGesture(perform: tapHandler)
        } else {
            content
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
