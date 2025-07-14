//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>

     var body: some View {
         NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
             VStack {
                 Text("Welcome, \(store.userName)")
                     .font(.headline)

                 Button(action: {
                     store.send(.detailPressed)
                 }, label:{
                     Text("Go to DetailView")
                         .foregroundStyle(.white)
                         .frame(width: 200, height: 42, alignment: .center)
                         .background(.blue)
                         .cornerRadius(8)
                 })
             }
             .padding()
         } destination: { store in
             switch store.case {
             case .detail(let store):
                 DetailView(store: store)
             }
         }
         .onAppear {
             store.send(.onAppear)
         }
     }
}

#Preview {
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    })
}
