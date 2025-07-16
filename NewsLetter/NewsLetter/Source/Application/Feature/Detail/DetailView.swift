//
//  DetailView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture

struct DetailView: View {
    @Bindable var store: StoreOf<DetailReducer>

    var body: some View {
        VStack {
            Text("오늘의 뉴스 기사 제목: \n\(store.title)")
            
            Text("[API 응답]")
            Text("setup: \(store.setup)")
            Text("delivery: \(store.delivery)")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    DetailView(store: Store(initialState: DetailReducer.State()) {
        DetailReducer()
    })
}
