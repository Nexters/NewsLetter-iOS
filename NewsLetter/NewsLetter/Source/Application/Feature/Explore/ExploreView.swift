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
        VStack(spacing: 12) {
            HStack {
                Text("전체 (\(store.state.data.count))")
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
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            UIScrollView.appearance().indicatorStyle = .white
            UIRefreshControl.appearance().tintColor = .white
            store.send(.onAppear)
        }
    }
}

#Preview {
    ExploreView(store: Store(initialState: ExploreReducer.State()) {
        ExploreReducer()
    })
}
