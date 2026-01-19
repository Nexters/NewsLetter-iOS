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
        var hasMore: Bool = false
        var nextOffset: Int = 0
        var isLoading: Bool = false
        var isPresentToast: Bool = false
    }
    
    enum Action {
        case onAppear
        case fetchFirstPage
        case fetchNextPage
        case fetchExploreCards(Int)
        case setData([ExploreCard])
        case setSelectedCard((Card, ColorPaletteName))
        case setHasMore(Bool)
        case setNextOffset(Int)
        case setIsLoading(Bool)
        case setIsPresentToast(Bool)
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
                return .send(.fetchFirstPage)
            case .fetchFirstPage:
                return .send(.fetchExploreCards(0))
            case .fetchNextPage:
                guard state.hasMore, !state.isLoading else { return .none }
                return .send(.fetchExploreCards(state.nextOffset))
            case .fetchExploreCards(let lastSeenOffset):
                state.isLoading = true
                return .run { [state] send in
                    do {
                        let requestDTO: ExploreCardRequestDTO = .init(
                            lastSeenOffset: Int64(lastSeenOffset),
                            size: 20
                        )
                        let response = try await cardClient.fetchExploreCards(requestDTO)
                        await send(.setHasMore(response.hasMore))
                        await send(.setNextOffset(response.nextOffset))
                        
                        if lastSeenOffset == 0 {
                            await send(.setData(response.contents))
                        } else {
                            await send(.setData(state.data + response.contents))
                        }
                    } catch let error {
                        print("[ExploreReducer] fetchExploreCard 에러발생: \(error.localizedDescription)")
                        await send(.setIsPresentToast(true))
                    }
                    await send(.setIsLoading(false))
                }
            case .setData(let data):
                state.data = data
                return .none
            case .setSelectedCard(let data):
                state.selectedCard = data
                return .none
            case .setHasMore(let bool):
                state.hasMore = bool
                return .none
            case .setNextOffset(let offset):
                state.nextOffset = offset
                return .none
            case .setIsLoading(let bool):
                state.isLoading = bool
                return .none
            case .setIsPresentToast(let bool):
                state.isPresentToast = bool
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
