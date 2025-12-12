//
//  ExploreReducer.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import Foundation
import Combine

import ComposableArchitecture

@Reducer
struct ExploreReducer {
    @ObservableState
    struct State {
        var colorList: [ColorPaletteName] = [
            .pointGreen300, .pointPink300,
            .pointLemonYellow300, .pointBlue300,
            .pointOrange300, .pointPurple300
        ]
        var data: [ExploreCard] = []
        var selectedCard: (Card, ColorPaletteName)? = nil
    }
    
    enum Action {
        case onAppear
        case fetchExploreCards
        case setData([ExploreCard])
        case setSelectedCard((Card, ColorPaletteName))
        case delegate(Delegate)
        
        @CasePathable
        enum Delegate {
            case presentExploreCard
        }
    }
    
    @Dependency(\.cardClient) var cardClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchExploreCards)
            case .fetchExploreCards:
                return .run { send in
                    do {
                        let requestDTO: ExploreCardRequestDTO = .init(lastSeenOffset: 0, size: 20) // TODO: 페이지네이션 구현 필요
                        let cards = try await cardClient.fetchExploreCards(requestDTO)
                        await send(.setData(cards))
                    } catch let error {
                        print("[ExploreReducer] fetchExploreCard 에러발생: \(error.localizedDescription)")
                        await send(.setData([]))
                    }
                }
            case .setData(let data):
                state.data = data
                return .none
            case .setSelectedCard(let data):
                state.selectedCard = data
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
