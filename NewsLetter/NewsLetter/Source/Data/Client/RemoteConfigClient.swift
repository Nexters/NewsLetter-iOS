//
//  RemoteConfigClient.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/23/25.
//

import ComposableArchitecture

@DependencyClient
struct RemoteConfigClient {
    static let manager = RemoteConfigManager()

    var fetch: @Sendable () async throws -> FirebaseConfig
}

extension RemoteConfigClient: DependencyKey {
    static var liveValue: Self = {
        return Self(
            fetch: {
                try await manager.fetchRemoteValues()
            }
        )
    }()
}

extension DependencyValues {
    var remoteConfigClient: RemoteConfigClient {
        get { self[RemoteConfigClient.self] }
        set { self[RemoteConfigClient.self] = newValue }
    }
}
