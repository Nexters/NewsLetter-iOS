//
//  NotificationPermissionBottomSheet.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/30/25.
//

import SwiftUI

struct NotificationPermissionBottomSheet: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var isPresented: Bool
    @State private var isCheckingPermission = false
    
    let successHandler: (() -> Void)
    
    var body: some View {
        VStack {
            Text("가장 먼저 새로운 소식을 받아보세요")
                .font(.head22_bold)
                .foregroundStyle(.semanticColor.text_strong)
            
            Text("매일 유용한 뉴스레터를 보내드려요.")
                .font(.body16_regular)
                .foregroundStyle(.semanticColor.text_tertiary)
                .padding(.top, 8)
            
            Button(action: {
                checkNotificationPermission()
            }) {
                RoundedRectangle(cornerRadius: 100)
                    .frame(height: 56)
                    .foregroundStyle(.semanticColor.fill_primaryInversion)
                    .padding(.horizontal, 16)
                    .overlay {
                        Text("알림 받기")
                            .font(.body16_semiBold)
                            .foregroundStyle(.semanticColor.text_strongInverse)
                    }
            }
            .padding(.top, 32)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && isCheckingPermission {
                checkNotificationStatusAndDismissIfAllowed()
            }
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    UserActionHistory.isAlreadySetNotification = true
                    successHandler()
                    isPresented = false
                } else {
                    isCheckingPermission = true
                    // TODO: 현재 앱 설정으로 이동은 하지만 알림메뉴가 표출되지 않는상황. 추후 알림메뉴 표출될 시 시나리오 테스트 필요
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func checkNotificationStatusAndDismissIfAllowed() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    isPresented = false
                }
                isCheckingPermission = false
            }
        }
    }
}

#Preview {
    NotificationPermissionBottomSheet(isPresented: .constant(true), successHandler: {})
}
