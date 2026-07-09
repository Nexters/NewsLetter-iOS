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
                return .run { send in
                    do {
                        guard let userId = UserInfo.userId else { return }
                        try await userClient.update(userId, dto)
                    } catch {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                    }
                }
            case .jobDetailSettingTapped:
                return .run { send in
                    do {
                        guard let userId = UserInfo.userId else { return }
                        let response = try await userClient.fetchUser(userId)
                        await send(.fetchUserInfoResponse(response))
                    } catch {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                    }
                }
            case .fetchUserInfoResponse(let response):
                state.selectedPreferences = response.preferences
                state.selectedWorkingExperience = response.workingExperience
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
            }
        }
        .forEach(\.path, action: \.path)
    }
}
