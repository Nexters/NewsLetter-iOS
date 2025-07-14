//
//  AppReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture

@Reducer
struct AppReducer {
    @ObservableState
    struct State {
        var home = HomeReducer.State()
    }
    
    enum Action {
        case home(HomeReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }
    }
}
