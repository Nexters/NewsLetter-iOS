//
//  NotificationPermissionBottomSheet.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/30/25.
//

import SwiftUI

import FirebaseAnalytics
import FirebaseMessaging

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
        .onAppear() {
            GA.pageview_bottom_sheet_notification()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && isCheckingPermission {
                checkNotificationStatusAndDismissIfAllowed()
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.sendTokenToServer()
                    GA.click_bottom_sheet_notification()
                    successHandler()
                    isPresented = false
                } else {
                    isCheckingPermission = true
                    isPresented = false
                }
            }
        }
    }

    private func sendTokenToServer() {
        guard let deviceToken = KeychainManager.shared.retrieveString(forKey: "deviceToken"),
              let fcmToken = UserInfo.fcmToken
        else {
            return
        }

        Task {
            do {
                let firebaseClient = FirebaseClient.liveValue
                try await firebaseClient.sendDeviceToken(deviceToken, fcmToken)
            } catch {
                print("=== ❌ FCM 토큰 등록 실패: \(error.localizedDescription)")
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
