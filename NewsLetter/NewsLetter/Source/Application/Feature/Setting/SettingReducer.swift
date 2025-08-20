//
//  SettingReducer.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/13/25.
//

import Foundation
import SwiftUI

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
        var isPresentToastMessage = false
        var navigateToPrivacyPolicy = false
        var navigateToTermsOfService = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case onDisappear
        case updateUser(UserUpdateRequestDTO)
        case setIsPresentJobDetailBottomSheet(Bool)
        case setIsPresentToastMessage(Bool)
        case setNavigateToPrivacyPolicy(Bool)
        case setNavigateToTermsOfService(Bool)
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
            case .setIsPresentJobDetailBottomSheet(let bool):
                state.isPresentJobDetailBottomSheet = bool
                return .none
            case .setIsPresentToastMessage(let bool):
                state.isPresentToastMessage = bool
                return .none
            case .setNavigateToPrivacyPolicy(let bool):
                state.navigateToPrivacyPolicy = bool
                return .none
            case .setNavigateToTermsOfService(let bool):
                state.navigateToTermsOfService = bool
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
