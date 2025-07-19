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
                     .foregroundStyle(.semanticColor.text_primary)

                 Button(action: {
                     store.send(.detailPressed)
                 }, label:{
                     Text("Go to DetailView")
                         .foregroundStyle(.white)
                         .frame(width: 200, height: 42, alignment: .center)
                         .background(.accentColor.orange)
                         .cornerRadius(8)
                 })

                 Text("IT 직장인이라면 알아야 할 주 4일제의 모든 것을 알려준다")
                     .font(.caption12_bold)
                     .frame(width: 179)
                     .foregroundStyle(ColorPalette.gray600)
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
