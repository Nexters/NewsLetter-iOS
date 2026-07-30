//
//  SettingReducer.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/13/25.
//

import Foundation
import SwiftUI

import FirebaseInstallations

import ComposableArchitecture

@Reducer
struct SettingReducer {
    @Reducer
    enum Path {
        
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var isPresentJobDetailBottomSheet = false
        var selectedPreferences: [Preference] = []
        var selectedWorkingExperience: WorkingExperience?
        var isCategoryChanged: Bool = false
        var isPresentNotificationPermissionBottomSheet = false
        var isPresentToastMessage = false
        var isPresentNotiToastMessage = false
        var isPresentTokenToast = false
        var navigateToPrivacyPolicy = false
        var navigateToTermsOfService = false
        var versionTapCount = 0
        var tokenToastText = ""
        var isTokenCopyable = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case onDisappear
        case updateUser(UserUpdateRequestDTO)
        case jobDetailSettingTapped
        case fetchUserInfoResponse(UserResponseDTO)
        case setIsPresentJobDetailBottomSheet(Bool)
        case setIsPresentNotificationPermissionBottomSheet(Bool)
        case setIsPresentToastMessage(Bool)
        case setIsPresentNotiToastMessage(Bool)
        case setIsPresentTokenToast(Bool)
        case setNavigateToPrivacyPolicy(Bool)
        case setNavigateToTermsOfService(Bool)
        case versionRowTapped
        case didReceiveInstallationToken(String?)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case categoryUpdated
        }
    }
    
    @Dependency(\.userClient) var userClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case .path(_):
                return .none
            case .onAppear:
                return .none
            case .onDisappear:
                return .none
            case .updateUser(let dto):
                // 경력만 바뀌고 관심 직군(preferences)이 그대로면 추천 컨텐츠에 영향이 없으므로 홈 새로고침을 생략합니다.
                let didPreferencesChange = Set(dto.preferences.map(\.rawValue)) != Set(state.selectedPreferences.map(\.rawValue))
                return .run { send in
                    do {
                        guard let userId = UserInfo.userId else { return }
                        try await userClient.update(userId, dto)
                        if didPreferencesChange {
                            await send(.delegate(.categoryUpdated))
                        }
                    } catch {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                    }
                }
            case .jobDetailSettingTapped:
                return .run { send in
                    do {
                        let userId: Int
                        if let existingUserId = UserInfo.userId {
                            userId = existingUserId
                        } else {
                            // 아직 로그인/등록이 끝나지 않은 상태(홈 진입 직후 등)라면 여기서 먼저 확보합니다.
                            guard let deviceToken = KeychainManager.shared.retrieveString(forKey: "deviceToken") else {
                                print("[SettingReducer] deviceToken이 없어 맞춤 설정을 열 수 없습니다.")
                                return
                            }
                            let fetchedUserId: Int
                            do {
                                fetchedUserId = try await userClient.login(UserLoginRequestDTO(deviceToken: deviceToken))
                            } catch {
                                fetchedUserId = try await userClient.register(UserRegisterRequestDTO(deviceToken: deviceToken))
                            }
                            UserInfo.userId = fetchedUserId
                            userId = fetchedUserId
                        }

                        let response = try await userClient.fetchUser(userId)
                        await send(.fetchUserInfoResponse(response))
                    } catch {
                        // TODO: 에러 핸들링
                        print("[SettingReducer] 맞춤 설정 조회 실패: \(error.localizedDescription)")
                    }
                }
            case .fetchUserInfoResponse(let response):
                state.selectedPreferences = response.preferences
                state.selectedWorkingExperience = response.workingExperience
                state.isCategoryChanged = response.isCategoryChanged
                state.isPresentJobDetailBottomSheet = true
                return .none
            case .setIsPresentJobDetailBottomSheet(let bool):
                state.isPresentJobDetailBottomSheet = bool
                return .none
            case .setIsPresentNotificationPermissionBottomSheet(let bool):
                state.isPresentNotificationPermissionBottomSheet = bool
                return .none
            case .setIsPresentToastMessage(let bool):
                state.isPresentToastMessage = bool
                return .none
            case .setIsPresentNotiToastMessage(let bool):
                state.isPresentNotiToastMessage = bool
                return .none
            case .setIsPresentTokenToast(let bool):
                state.isPresentTokenToast = bool
                return .none
            case .setNavigateToPrivacyPolicy(let bool):
                state.navigateToPrivacyPolicy = bool
                return .none
            case .setNavigateToTermsOfService(let bool):
                state.navigateToTermsOfService = bool
                return .none
            case .versionRowTapped:
                state.versionTapCount += 1

                guard state.versionTapCount >= 10 else {
                    return .none
                }

                state.versionTapCount = 0
                return .run { send in
                    do {
                        let authTokenResult = try await Installations.installations()
                            .authTokenForcingRefresh(true)
                        await send(.didReceiveInstallationToken(authTokenResult.authToken))
                    } catch {
                        await send(.didReceiveInstallationToken(nil))
                    }
                }
            case .didReceiveInstallationToken(let token):
                if let token, token.isEmpty == false {
                    state.tokenToastText = token
                    state.isTokenCopyable = true
                } else {
                    state.tokenToastText = "설치 토큰을 받지 못했어요."
                    state.isTokenCopyable = false
                }
                state.isPresentTokenToast = true
                return .none
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
