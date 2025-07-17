//
//  DetailReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import Foundation
import Combine

import ComposableArchitecture

@Reducer
struct DetailReducer {
    @ObservableState
    struct State {
        var title: String = "애플 ‘비밀번호 앱’ 서버를 스위프트로 바꿨더니"
        var setup: String = "loading..."
        var delivery: String = "loading..."
        var cancellables: Set<AnyCancellable> = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case setJoke(Joke)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.jokeClient) var jokeClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let res = try await jokeClient.fetchJoke()
                    await send(.setJoke(res))
                }
            case let .setJoke(joke):
                state.setup = joke.setup
                state.delivery = joke.delivery
                return .none
            default:
                return .none
            }
        }
    }
}
