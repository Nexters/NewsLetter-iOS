//
//  DetailReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture

@Reducer
struct DetailReducer {
    @ObservableState
    struct State {
        var title: String = "애플 ‘비밀번호 앱’ 서버를 스위프트로 바꿨더니"
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
    }
}
