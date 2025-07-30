//
//  APPView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture
import FirebaseRemoteConfig

struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>
    @StateObject private var remoteConfigManager = RemoteConfigManager()

    var body: some View {
        HomeView(store: store.scope(state: \.home, action: \.home),
                 colorFlag: remoteConfigManager.colorFlag
        )
    }
}

class RemoteConfigManager: ObservableObject {
    @Published var colorFlag: String = "B"
    private var remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 86400 // 하루 1번
        remoteConfig.configSettings = settings
        fetchRemoteValues()
    }

    func fetchRemoteValues() {
        remoteConfig.fetchAndActivate { status, error in
            if error != nil {
                print("Remote Config fetch failed: \(error!.localizedDescription)")
                return
            }

            let rawFlag = self.remoteConfig["testType"].stringValue
            let colorFlag = (rawFlag == "A" || rawFlag == "B") ? rawFlag : "B"
            DispatchQueue.main.async {
                self.colorFlag = colorFlag
                print("색상 실험 그룹 - \(rawFlag)")
            }
        }
    }
}
