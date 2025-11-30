//
//  AppReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture

@Reducer
struct AppReducer {
    typealias Flags = (colorFlag: String, mainDescFlag: String)
    
    @ObservableState
    struct State {
        var home = HomeReducer.State()
        var isLoading: Bool = true
    }
    
    enum Action {
        case home(HomeReducer.Action)
        case onAppear
        case remoteConfigResponse(Result<Flags, Error>)
    }
    
    @Dependency(\.remoteConfigClient) var remoteConfigClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isLoading else { return .none }
                return .run { send in
                    await send(.remoteConfigResponse(
                        Result { try await self.remoteConfigClient.fetch() }
                    ))
                }
            case .remoteConfigResponse(.success(let config)):
                state.isLoading = false
                return .send(.home(.setFlags(config)))
            case .remoteConfigResponse(.failure(let error)):
                state.isLoading = false
                print("Remote Config Fetch Error: \(error.localizedDescription)")
                return .none
            default:
                return .none
            }
        }
    }
}
