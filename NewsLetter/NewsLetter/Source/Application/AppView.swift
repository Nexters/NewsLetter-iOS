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
    }
}
