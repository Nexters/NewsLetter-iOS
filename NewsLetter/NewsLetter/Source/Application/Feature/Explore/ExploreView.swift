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
        static let cardCornerRadius: CGFloat = 16
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
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: Metrics.gridSpacing) {
                    ForEach(store.state.data, id: \.id) { data in
                        ExploreCardCell(data: data)
                            .frame(height: Metrics.cardHeight)
                    }
                }
            }
        }
        .padding(Metrics.horizontalPadding)
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ExploreView(store: Store(initialState: ExploreReducer.State()) {
        ExploreReducer()
    })
}
