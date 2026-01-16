//
//  APPView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture


struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.isLoading {
                VStack {
                    ProgressView()
                    Text("로딩 중...")
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.send(.onSceneActive)
            }
        }
        .alert(
            "업데이트 알림",
            isPresented: Binding(
                get: { store.updateStatus != .none },
                set: { newValue in
                    if case .forced = store.updateStatus {
                    } else {
                        if !newValue { store.send(.setUpdateStatus(.none)) }
                    }
                }
            )
        ) {
            updateActions
        } message: {
            if case let .forced(_, message) = store.updateStatus { Text(message) }
            else if case let .optional(_, message) = store.updateStatus { Text(message) }
        }
    }

    @ViewBuilder
    private var updateActions: some View {
        switch store.updateStatus {
        case let .forced(url, _):
            Button("업데이트 하러 가기") { openStore(url) }
        case let .optional(url, _):
            Button("업데이트") { openStore(url) }
            Button("나중에", role: .cancel) { }
        case .none:
            EmptyView()
        }
    }

    private func openStore(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

}
