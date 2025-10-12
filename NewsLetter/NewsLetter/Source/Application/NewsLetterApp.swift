//
//  NewsLetterApp.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon

@main
struct NewsLetterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let store = Store(initialState: AppReducer.State()) { AppReducer() }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let deviceToken = KeychainManager.shared.retrieveString(forKey: "deviceToken") {
            print("Device Token: \(deviceToken)")
        } else {
            let newDeviceToken = UUID().uuidString
            KeychainManager.shared.saveString(newDeviceToken, forKey: "deviceToken")
            print("New Device Token: \(newDeviceToken)")
        }

        FirebaseApp.configure()

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        KakaoSDK.initSDK(appKey: "3eb3851f7f6457accc8d6fd4585db5e2")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        if let fcmToken = fcmToken {
            UserInfo.fcmToken = fcmToken
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        completionHandler()
    }

}
