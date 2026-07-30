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
    
    var login: (UserLoginRequestDTO) async throws -> Int
    var register: (UserRegisterRequestDTO) async throws -> Int
    var update: (Int, UserUpdateRequestDTO) async throws -> Void
    var fetchUser: (Int) async throws -> UserResponseDTO
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
        login: { requestDTO in
            let response = try await apiClient.request(UserAPI.login(requestDTO))
            let dto = try response.map(UserLoginResponseDTO.self)
            return dto.id
        },
        register: { requestDTO in
            let response = try await apiClient.request(UserAPI.register(requestDTO))
            let dto = try response.map(UserRegisterResponseDTO.self)
            return dto.id
        },
        update: { userId, requestDTO in
            let _ = try await apiClient.request(UserAPI.update(userId: userId, requestDTO: requestDTO))
        },
        fetchUser: { userId in
            let response = try await apiClient.request(UserAPI.fetchUser(userId: userId))
            return try response.map(UserResponseDTO.self)
        }
       )
    }()

    static var previewValue: UserClient = {
        return UserClient(
            login: { _ in return 0 },
            register: { _ in return 0 },
            update: { _, _ in return },
            fetchUser: { _ in
                UserResponseDTO(id: 0, preferences: [.frontend], workingExperience: .student, isOnboarded: false, isCategoryChanged: false, categoryChangeCount: 0)
            }
        )
    }()
    
    static var testValue: UserClient = previewValue
}
