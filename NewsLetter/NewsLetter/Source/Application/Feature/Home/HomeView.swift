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
    let colorFlag: String
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

                    if store.cardColors.count == store.cardData.count {
                        VStack(spacing: -35) {
                            ForEach(Array(store.state.cardData.enumerated()), id: \.offset) { index, item in
                                let (type, title, category, source) = item
                                CardView(
                                    cardType: type,
                                    color: store.cardColors[index],
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
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.opacity)
                .onAppear {
                    store.send(.onAppear(colorFlag: self.colorFlag))
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
        }   destination: { store in
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
    },
             colorFlag: "A")
}

