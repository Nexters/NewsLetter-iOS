//
//  NewsLetterApp.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture
import FirebaseCore

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
        return true
    }
}
