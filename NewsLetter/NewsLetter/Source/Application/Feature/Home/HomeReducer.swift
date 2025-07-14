//
//  HomeReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @Reducer
    enum Path {
        case detail(DetailReducer)
    }

    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var userName: String = "조은"
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case detailPressed
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                print("HomeView Appear")
                return .none

            case .detailPressed:
                state.path.append(.detail(DetailReducer.State()))
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
