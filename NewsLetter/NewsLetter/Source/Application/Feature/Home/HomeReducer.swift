//
//  HomeReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import Foundation
import SwiftUI

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @Reducer
    enum Path {
        case setting(SettingReducer)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
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
        var colorFlag: String = ""
        var cardColors: [Color] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear(colorFlag: String)
        case onDisappear
        case settingPressed
        case tick
        case startTimer
        case setColorPalette([Color])
        case fetchCards
        case loginUser
        case registerUser
        case updateUser(UserUpdateRequestDTO)
        case setCards([Card])
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
            case .path(_):
                return .none
            case let .onAppear(colorFlag):
                var effects: [Effect<Action>] = []
                
                state.colorFlag = colorFlag
                state.todayDate = DateCalculator.formattedDateStringForTitle()

                let todayString = DateCalculator.formattedDateString()
                let lastVisitString = UserInfo.lastCardFetchDate.map {
                    DateCalculator.formattedDateString(from: $0)
                } ?? ""

                if todayString == lastVisitString ,
                   let cachedCards = UserInfo.cachedDailyCards,
                   !cachedCards.isEmpty,
                   let cachedColors = UserInfo.cachedDailyColors?.map({ $0.color }),
                   !cachedColors.isEmpty {

                    if UserActionHistory.isChangedCareer == true {
                        effects.append(.send(.fetchCards))
                        UserActionHistory.isChangedCareer = false
                    } else {
                        state.cardData = cachedCards
                        state.cardColors = cachedColors
                    }

                } else {
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
            case .settingPressed:
                state.path.append(.setting(SettingReducer.State()))
                return .none
            case .startTimer:
                guard state.timerIsRunning == false else {
                    return .none
                }
                state.timerIsRunning = true
                state.remainingSeconds = DateCalculator.secondsUntilMidnight(from: self.now)

                return .run { send in
                    await send(.startTimer)
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
                    UserInfo.cachedDailyColors = nil

                    return .send(.fetchCards)
                }
                return .none
            case .fetchCards:
                return .run { send in
                    do {
                        // TODO: 고정으로 들어가는 userId 값 변경 필요
                        let userId = String(UserInfo.userId ?? 3)
                        let publishedDate: String? = nil
                        
                        let cards = try await cardClient.fetchCards(userId, publishedDate)
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
                state.cardData = cards
                UserInfo.cachedDailyCards = cards

                if cards.isEmpty {
                    return .none
                }

                UserInfo.lastCardFetchDate = Date()

                if state.colorFlag == "A" {
                    let colors = generateNewDailyColors(for: cards)
                    let colorNames = colors.compactMap { ColorPaletteName.from(color: $0) }

                    UserInfo.cachedDailyColors = colorNames

                    return .send(.setColorPalette(Array(colors)))
                } else {
                    let fixedColors: [Color] = [
                        ColorPalette.pointPurple200,
                        ColorPalette.pointOrange400,
                        ColorPalette.pointBlue300,
                        ColorPalette.pointLemonYellow300,
                        ColorPalette.pointPink300,
                        ColorPalette.pointGreen300
                    ]
                    let colorNames = fixedColors.compactMap { ColorPaletteName.from(color: $0) }
                    UserInfo.cachedDailyColors = colorNames

                    return .send(.setColorPalette(fixedColors))
                }
            }
        }
        .forEach(\.path, action: \.path)
    }

    private func generateNewDailyColors(for cardData: [Card], forceShuffle: Bool = true) -> [Color] {
        let colorFamilies: [[Color]] = [
            [ColorPalette.pointBlue300, ColorPalette.pointBlue200, ColorPalette.pointBlue400],
            [ColorPalette.pointOrange400, ColorPalette.pointOrange300, ColorPalette.pointOrange500],
            [ColorPalette.pointPink300, ColorPalette.pointPink200, ColorPalette.pointPink400],
            [ColorPalette.pointPurple200, ColorPalette.pointPurple150, ColorPalette.pointPurple300],
            [ColorPalette.pointGreen300, ColorPalette.pointGreen200, ColorPalette.pointGreen400],
            [ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellow200, ColorPalette.pointLemonYellow400]
        ]

        let shuffledFamilies = colorFamilies.shuffled()
        let uniqueCategories = Array(Set(cardData.map { $0.topKeyword }))
        var categoryToFamilyMap: [String: [Color]] = [:]
        for (index, category) in uniqueCategories.enumerated() {
            categoryToFamilyMap[category] = shuffledFamilies[index % shuffledFamilies.count]
        }
        var categoryUsageCount: [String: Int] = [:]
        return cardData.map { card in
            let category = card.topKeyword
            guard let colorFamily = categoryToFamilyMap[category] else {
                return .gray
            }
            let usageIndex = categoryUsageCount[category, default: 0]
            let selectedColor = colorFamily[usageIndex % colorFamily.count]
            categoryUsageCount[category, default: 0] += 1
            return selectedColor
        }
    }
}
