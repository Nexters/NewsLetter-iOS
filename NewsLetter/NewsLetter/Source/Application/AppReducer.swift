//
//  AppReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppReducer {
    
    enum UpdateStatus: Equatable {
        case none
        case optional(storeURL: String, message: String)
        case forced(storeURL: String, message: String)
    }

    @ObservableState
    struct State {
        var home = HomeReducer.State()
        var isLoading: Bool = false
        var isFirstAppear: Bool = true
        var updateStatus: UpdateStatus = .none
    }

    enum Action {
        case home(HomeReducer.Action)
        case onAppear
        case onSceneActive
        case remoteConfigResponse(Result<FirebaseConfig, Error>)
        case setUpdateStatus(UpdateStatus)
    }

    @Dependency(\.remoteConfigClient) var remoteConfigClient

    var body: some Reducer<State, Action> {

        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear, .onSceneActive:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false
                state.isLoading = true
                return .run { send in
                    await send(.remoteConfigResponse(
                        Result { try await self.remoteConfigClient.fetch() }
                    ))
                }
                
            case .remoteConfigResponse(.success(let config)):
                state.isLoading = false

                let currentVersion = AppInfo.appVersion
                if currentVersion.compare(config.minVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .forced(storeURL: config.storeURL, message: config.updateMessage)
                } else if currentVersion.compare(config.latestVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .optional(storeURL: config.storeURL, message: config.updateMessage)
                } else {
                    state.updateStatus = .none
                }
                return .none

            case .remoteConfigResponse(.failure(let error)):
                print("Remote Config Fetch Error: \(error.localizedDescription)")
                state.isLoading = false
                state.updateStatus = .none
                return .none
            case let .setUpdateStatus(status):
                state.updateStatus = status
                return .none

            default:
                return .none
            }
        }
    }
}
