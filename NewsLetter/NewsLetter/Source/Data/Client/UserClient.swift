//
//  UserClient.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Combine

import ComposableArchitecture
import Moya

@DependencyClient
struct UserClient {
    static let apiClient = MoyaAPIClient()
    
    var register: (UserRegisterRequestDTO) async throws -> Int
    var update: (Int, UserUpdateRequestDTO) async throws -> Void
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}

extension UserClient: DependencyKey {
    static var liveValue: UserClient = {
       return UserClient(
        register: { requestDTO in
            let response = try await apiClient.request(UserAPI.register(requestDTO))
            let dto = try response.map(UserRegisterResponseDTO.self)
            return dto
        },
        update: { userId, requestDTO in
            let _ = try await apiClient.request(UserAPI.update(userId: userId, requestDTO: requestDTO))
        }
       )
    }()
    
    static var previewValue: UserClient = {
        return UserClient(
            register: { _ in return 0 },
            update: { _, _ in return }
        )
    }()
    
    static var testValue: UserClient = previewValue
}
