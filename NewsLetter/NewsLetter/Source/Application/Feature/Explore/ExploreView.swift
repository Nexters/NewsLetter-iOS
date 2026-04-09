//
//  ExploreView.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import SwiftUI

import ComposableArchitecture

struct ExploreView: View {
    
    private enum Metrics {
        static let horizontalPadding: CGFloat = 16
        static let gridSpacing: CGFloat = 8
        static let cardHeight: CGFloat = (Device.width - (horizontalPadding * 2 + gridSpacing)) / 2
    }
    
    @Bindable var store: StoreOf<ExploreReducer>
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: Metrics.gridSpacing),
        GridItem(.flexible(), spacing: Metrics.gridSpacing)
    ]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
        VStack(spacing: 12) {
            HStack {
                Text("전체 (\(store.state.totalCount))")
                    .font(.body14_bold)
                    .foregroundStyle(.semanticColor.text_strongInverse)
                Spacer()
            }
            .padding(Metrics.horizontalPadding)
            
            ScrollView(showsIndicators: true) {
                LazyVGrid(columns: columns, spacing: Metrics.gridSpacing) {
                    ForEach(store.state.data.indices, id: \.self) { index in
                        let colorIndex = index % store.state.colorList.count
                        let data = store.state.data[index]
                        let colorPallete = store.state.colorList[colorIndex]
                        let isLastItem = index == store.state.data.count - 1
                        
                        ExploreCardCell(
                            data: data,
                            color: colorPallete.color
                        )
                        .frame(height: Metrics.cardHeight)
                        .onTapGesture {
                            let selectedCard = (data.toCard(), colorPallete)
                            store.send(.setSelectedCard(selectedCard))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                store.send(.delegate(.presentExploreCard))
                            }
                        }
                        .onAppear {
                            if isLastItem {
                                store.send(.fetchNextPage)
                            }
                        }
                    }
                }
                .padding(Metrics.horizontalPadding)
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 1000_000_000)
                await store.send(.fetchFirstPage).finish()
            }
            .toastMessage(
                isPresented: Binding(
                    get: { store.state.isPresentToast },
                    set: { store.send(.setIsPresentToast($0)) }
                ),
                text: "마지막 페이지에요! 😊",
                bottomPadding: Device.safeAreaInsets.bottom
            )
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            UIScrollView.appearance().indicatorStyle = .white
            UIRefreshControl.appearance().tintColor = .white
            store.send(.onAppear)
        }

        Button {
            store.send(.delegate(.reportNewsletterButtonTapped))
        } label: {
            HStack(spacing: 6) {
                Image("pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text("뉴스레터 제보")
                    .font(.body14_semiBold)
                    .foregroundStyle(.semanticColor.text_secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .padding(.leading, 16)
        .padding(.bottom, Device.safeAreaInsets.bottom + 16)

        }
    }
}

#Preview {
    ExploreView(store: Store(initialState: ExploreReducer.State()) {
        ExploreReducer()
    })
}
