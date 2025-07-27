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
    @State private var isPresentModal: Bool = false
    @State private var selectedIndex: Int?
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
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
                    
                    Spacer()
                    
                    VStack(spacing: -35) {
                        ForEach(store.state.cardData, id: \.0) { type, title, category, source in
                            CardView(
                                cardType: type,
                                title: title,
                                category: category,
                                source: source,
                                onTap: {
                                    // FIXME: 추후 카드 데이터 순서 논의 필요
                                    selectedIndex = store.state.cardData.reversed().firstIndex(where: { $0.0 == type })
                                    isPresentModal = true
                                }
                            )
                        }
                    }
                    .padding(.bottom, -20)
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.opacity)
                .onAppear {
                    store.send(.onAppear)
                }
                .onDisappear {
                    store.send(.onDisappear)
                }
                
                if isPresentModal {
                    CarouselModalView(isPresented: $isPresentModal, currentPage: $selectedIndex)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isPresentModal)
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
