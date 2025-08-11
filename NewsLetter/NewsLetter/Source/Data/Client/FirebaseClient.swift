//
//  FirebaseClient.swift
//  NewsLetter
//
//  Created by 이조은 on 8/7/25.
//

import Combine

import ComposableArchitecture
import Moya

@DependencyClient
struct FirebaseClient {
    static let apiClient = MoyaAPIClient()

    var sendDeviceToken: (_ deviceToken: String, _ fcmToken: String, _ deviceType: String) async throws -> Void
}

extension DependencyValues {
    var firebaseClient: FirebaseClient {
        get { self[FirebaseClient.self] }
        set { self[FirebaseClient.self] = newValue }
    }
}

extension FirebaseClient: DependencyKey {
    static var liveValue: FirebaseClient = {
        return FirebaseClient(
            sendDeviceToken: { deviceToken, fcmToken, deviceType in
                let dto = RegisterNotificationRequestDTO(
                    deviceToken: deviceToken,
                    fcmToken: fcmToken,
                    deviceType: "IOS"
                )
                _ = try await apiClient.request(FirebaseAPI.registerNotification(dto: dto))
            }
        )
    }()

    static var previewValue: FirebaseClient = {
        return FirebaseClient(
            sendDeviceToken: { _, _, _ in
                print("📦 preview sendDeviceToken")
            }
        )
    }()

    static var testValue: FirebaseClient = previewValue
}
