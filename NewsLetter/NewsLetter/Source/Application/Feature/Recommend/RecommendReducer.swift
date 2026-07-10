//
//  RecommendReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import Foundation
import SwiftUI

import ComposableArchitecture
import Moya

@Reducer
struct RecommendReducer {
    
    @ObservableState
    struct State {
        var todayDate: String = ""
        var timerIsRunning: Bool = false
        var remainingSeconds: Int = 0
        var formattedTime: String {
            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        var cardData: [Card] = []
        var cardColors: [ColorSet] = []
        var isPresentModal: Bool = false
        var isRefreshLoading: Bool = false
        // 카드 최초 로딩 여부. true일 때만 스켈레톤을 노출합니다.
        var isCardLoading: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        case refreshButtonPressed
        case retryFetchCards
        case tick
        case startTimer
        case setColorPalette([ColorSet])
        case fetchCards
        case loginUser
        case registerUser
        case updateUser(UserUpdateRequestDTO)
        case setCards([Card])
        case delegate(Delegate)
        case setIsPresentModal(Bool)
        case setIsRefreshLoading(Bool)
        
        @CasePathable
        enum Delegate {
            case presentModal(Bool)
            case presentNotificationPermissionBottomSheet(Bool)
            case presentJobDetailBottomSheet(Bool)
        }
    }
    
    private enum CancelID { case timer }
    
    @Dependency(\.date.now) var now
    @Dependency(\.continuousClock) var clock
    @Dependency(\.cardClient) var cardClient
    @Dependency(\.userClient) var userClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case .onAppear:
                var effects: [Effect<Action>] = []
                state.todayDate = DateCalculator.formattedDateStringForTitle()
                
                let todayString = DateCalculator.formattedDateString()
                let lastVisitString = UserInfo.lastCardFetchDate.map {
                    DateCalculator.formattedDateString(from: $0)
                } ?? ""
                
                if todayString == lastVisitString ,
                   let cachedCards = UserInfo.cachedDailyCards,
                   !cachedCards.isEmpty {

                    if UserActionHistory.isChangedCareer == true {
                        state.isCardLoading = true
                        effects.append(.send(.fetchCards))
                        UserActionHistory.isChangedCareer = false
                    } else {
                        state.cardData = cachedCards
                        state.cardColors = cachedCards.colorSet
                    }

                } else {
                    state.isCardLoading = true
                    effects.append(.send(.fetchCards))
                }
                
                UserInfo.lastCardFetchDate = Date()
                
                let timerEffect = Effect<Action>.send(.startTimer)
                let loginEffect = Effect<Action>.send(.loginUser)
                let delayEffect = Effect<Action>.run { _ in
                    try await clock.sleep(for: .seconds(0.5))
                }
                let restEffect = Effect<Action>.merge(effects)
                return .concatenate(timerEffect, loginEffect, delayEffect, restEffect)
                
            case let .setColorPalette(colors):
                state.cardColors = colors
                return .none
                
            case .onDisappear:
                state.timerIsRunning = false
                return .cancel(id: CancelID.timer)
            case .refreshButtonPressed:
                return .run { send in
                    do {
                        await send(.setIsRefreshLoading(true))
                        let userId = String(UserInfo.userId ?? 3)
                        let newCards = try await cardClient.refreshCards(RefreshCardsRequestDTO(userId: userId))
                        await send(.setCards(newCards))
                        await send(.setIsRefreshLoading(false))
                        UserActionHistory.useRefreshDate = Date()
                    } catch let error {
                        await send(.setIsRefreshLoading(false))
                        print(error.localizedDescription)
                        guard let error = error as? MoyaError else { return }
                        
                        if error.response?.statusCode == 400 {
                            UserActionHistory.useRefreshDate = Date()
                        }
                    }
                }
            case .retryFetchCards:
                state.isCardLoading = true
                return .send(.fetchCards)
            case .startTimer:
                state.timerIsRunning = true
                state.remainingSeconds = DateCalculator.secondsUntilMidnight(from: self.now)
                
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                
            case .tick:
                if state.remainingSeconds > 0 {
                    state.remainingSeconds -= 1
                } else {
                    state.todayDate = DateCalculator.formattedDateStringForTitle()
                    state.remainingSeconds = DateCalculator.secondsUntilMidnight(from: self.now)
                    
                    UserInfo.lastCardFetchDate = nil
                    UserInfo.cachedDailyCards = nil
                    
                    return .send(.fetchCards)
                }
                return .none
            case .fetchCards:
                return .run { send in
                    do {
                        // TODO: 고정으로 들어가는 userId 값 변경 필요
                        let userId = String(UserInfo.userId ?? 3)
                        let publishedDate: String? = nil

                        let cards = try await cardClient.fetchCards(FetchCardsRequestDTO(userId: userId, publishedDate: publishedDate))
                        await send(.setCards(cards))
                    } catch {
                        await send(.setCards([]))
                    }
                }
            case .loginUser:
                return .run { send in
                    do {
                        guard let deviceToken = KeychainManager.shared.retrieveString(forKey: "deviceToken") else {
                            return
                        }
                        let requestDTO = UserLoginRequestDTO(deviceToken: deviceToken)
                        let userId = try await userClient.login(requestDTO)
                        UserInfo.userId = userId
                    } catch let error {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                        await send(.registerUser)
                    }
                }
            case .registerUser:
                return .run { send in
                    do {
                        guard let deviceToken = KeychainManager.shared.retrieveString(forKey: "deviceToken") else {
                            return
                        }
                        let requestDTO = UserRegisterRequestDTO(deviceToken: deviceToken)
                        let userId = try await userClient.register(requestDTO)
                        UserInfo.userId = userId
                    } catch let error {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                    }
                }
            case .updateUser(let dto):
                return .run { send in
                    do {
                        guard let userId = UserInfo.userId else { return }
                        try await userClient.update(userId, dto)
                    } catch {
                        // TODO: 에러 핸들링
                        print(error.localizedDescription)
                    }
                }
            case .setCards(let cards):
                state.isCardLoading = false
                state.cardData = cards
                UserInfo.cachedDailyCards = cards
                
                if cards.isEmpty {
                    return .none
                }

                UserInfo.lastCardFetchDate = Date()
                return .send(.setColorPalette(cards.colorSet))
            case .setIsPresentModal(let bool):
                state.isPresentModal = bool
                return .none
            case .setIsRefreshLoading(let bool):
                state.isRefreshLoading = bool
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
