//
//  RemoteConfigManager.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/23/25.
//

import FirebaseRemoteConfig

class RemoteConfigManager {
    private let remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 86400
        remoteConfig.configSettings = settings
    }

    func fetchRemoteValues() async throws -> (colorFlag: String, mainDescFlag: String) {
        _ = try await remoteConfig.fetchAndActivate()
        
        let rawFlag = self.remoteConfig["testType"].stringValue
        let rawFlag2 = self.remoteConfig["main_desc"].stringValue
        let colorFlag = (rawFlag == "A" || rawFlag == "B") ? rawFlag : "B"
        let mainDescFlag = (rawFlag2 == "T" || rawFlag2 == "F") ? rawFlag2 : "F"
        
        print("색상 실험 그룹 - \(colorFlag)")
        return (colorFlag, mainDescFlag)
    }
}
