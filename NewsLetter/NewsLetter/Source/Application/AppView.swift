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
        if remoteConfigManager.isLoading {
            // 로딩 중일 때 보여줄 화면 (추가되면 좋을 것 같아요)
        } else {
            HomeView(
                store: store.scope(state: \.home, action: \.home),
                colorFlag: remoteConfigManager.colorFlag
            )
        }
    }
}

class RemoteConfigManager: ObservableObject {
    @Published var colorFlag: String = "B"
    @Published var isLoading: Bool = true

    private var remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 86400
        remoteConfig.configSettings = settings
        fetchRemoteValues()
    }

    func fetchRemoteValues() {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Remote Config fetch failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            let rawFlag = self.remoteConfig["testType"].stringValue
            let colorFlag = (rawFlag == "A" || rawFlag == "B") ? rawFlag : "B"

            DispatchQueue.main.async {
                self.colorFlag = colorFlag
                self.isLoading = false
                print("색상 실험 그룹 - \(colorFlag)")
            }
        }
    }
}
