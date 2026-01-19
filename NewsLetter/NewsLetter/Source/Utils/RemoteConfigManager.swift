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

    func fetchRemoteValues() async throws -> FirebaseConfig {
        try await remoteConfig.fetchAndActivate()

        let jsonString = self.remoteConfig["app_update_info"].stringValue

        guard !jsonString.isEmpty,
              let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "RemoteConfigError", code: -1, userInfo: [NSLocalizedDescriptionKey: "데이터가 없거나 형식이 잘못되었습니다."])
        }

        let dto = try JSONDecoder().decode(UpdateInfoDTO.self, from: data)

        let rawFlag = self.remoteConfig["testType"].stringValue
        let rawFlag2 = self.remoteConfig["main_desc"].stringValue
        let colorFlag = (rawFlag == "A" || rawFlag == "B") ? rawFlag : "B"
        let mainDescFlag = (rawFlag2 == "T" || rawFlag2 == "F") ? rawFlag2 : "F"

        //print("RemoteConfig 로드 상태: \(status)")
        //print("실험 그룹: 색상(\(colorFlag)), 메인설명(\(mainDescFlag))")

        return FirebaseConfig(
            colorFlag: colorFlag,
            mainDescFlag: mainDescFlag,
            minVersion: dto.min_version,
            latestVersion: dto.latest_version,
            storeURL: dto.store_url,
            updateMessage: dto.message ?? "업데이트가 필요합니다."
        )
    }
}
