//
//  ExploreReducer.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import Foundation
import Combine

import ComposableArchitecture

private extension Preference {
    // GET /api/newsletters/explore/contents 의 categoryIds 파라미터 스펙 (1: BE, 2: FE, 3: iOS, 4: Android, 5: DevOps)
    var exploreCategoryId: String {
        switch self {
        case .backend:  return "1"
        case .frontend: return "2"
        case .iOS:      return "3"
        case .android:  return "4"
        case .devops:   return "5"
        }
    }
}

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
        var sortDirection: SortDirection = .desc
        var selectedCard: (Card, ColorPaletteName)? = nil
        var selectedCategories: Set<Preference> = []
        var hasMore: Bool = false
        var nextOffset: Int = 0
        var totalCount: Int = 0
        var isLoading: Bool = false
        var isPresentToast: Bool = false
    }
    
    enum Action {
        case onAppear
        case fetchFirstPage
        case fetchNextPage
        case fetchExploreCards(Int)
        case setResponse(ExploreCardResponse, isFirstPage: Bool, prevData: [ExploreCard])
        case setSelectedCard((Card, ColorPaletteName))
        case toggleCategory(Preference?)
        case setSortDirection(SortDirection)
        case setIsLoading(Bool)
        case setIsPresentToast(Bool)
        case delegate(Delegate)
        
        @CasePathable
        enum Delegate {
            case presentExploreCard
            case reportNewsletterButtonTapped
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
                        let categoryIds = state.selectedCategories.isEmpty
                            ? nil
                            : state.selectedCategories.map(\.exploreCategoryId)
                        let requestDTO: ExploreCardRequestDTO = .init(
                            lastSeenOffset: Int64(lastSeenOffset),
                            size: 20,
                            sort: Sort.published.rawValue.uppercased(),
                            direction: state.sortDirection.rawValue.uppercased(),
                            categoryIds: categoryIds
                        )
                        let response = try await cardClient.fetchExploreCards(requestDTO)
                        await send(.setResponse(response, isFirstPage: lastSeenOffset == 0, prevData: state.data))
                    } catch let error {
                        print("[ExploreReducer] fetchExploreCard 에러발생: \(error.localizedDescription)")
                        await send(.setIsPresentToast(true))
                    }
                    await send(.setIsLoading(false))
                }
            case .setResponse(let response, let isFirstPage, let prevData):
                state.totalCount = response.totalCount
                state.hasMore = response.hasMore
                state.nextOffset = response.nextOffset
                state.data = isFirstPage ? response.contents : prevData + response.contents
                return .none
            case .setSelectedCard(let data):
                state.selectedCard = data
                return .none
            case .toggleCategory(let preference):
                guard let preference else {
                    state.selectedCategories.removeAll()
                    return .send(.fetchFirstPage)
                }
                if state.selectedCategories.contains(preference) {
                    state.selectedCategories.remove(preference)
                } else {
                    state.selectedCategories.insert(preference)
                }
                return .send(.fetchFirstPage)
            case .setSortDirection(let sortDirection):
                state.sortDirection = sortDirection
                return .send(.fetchFirstPage)
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
