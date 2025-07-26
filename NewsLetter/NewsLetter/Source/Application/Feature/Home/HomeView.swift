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
                Text("\(store.state.todayDate)\nToday’s Hot News")
                    .font(Font.custom("Jalnan Gothic", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.semanticColor.text_strong)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(store.state.formattedTime)
                    .font(.body16_semiBold)
                    .foregroundColor(.semanticColor.state_negative_primary)
                    .padding(.top, 8)
                    .padding(.bottom, 68)
                
                Spacer()
                
                VStack(spacing:-30) {
                    CardView(cardType: .one, title: "메가커피 컵빙수의 품절 대란", category: "Kotlin", source: "안드로이드 위클리")
                    CardView(cardType: .two, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
                    CardView(cardType: .three, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
                    CardView(cardType: .four, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
                    CardView(cardType: .five, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
                    CardView(cardType: .six, title: "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", category: "Kotlin", source: "안드로이드 위클리")
                }
                .padding(.bottom, -20)
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
        } destination: { store in
            switch store.case {
            case .detail(let store):
                DetailView(store: store)
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    })
}
