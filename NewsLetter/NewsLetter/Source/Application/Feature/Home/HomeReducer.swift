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
        case detail(DetailReducer)
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
        case tick
        case timerStarted
        case setColorPalette([Color])
        case fetchCards
        case setCards([Card])
    }
    
    private enum CancelID { case timer }
    
    @Dependency(\.date.now) var now
    @Dependency(\.continuousClock) var clock
    @Dependency(\.cardClient) var cardClient
    
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
                
                if !state.timerIsRunning {
                    state.timerIsRunning = true
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy.MM.dd"
                    state.todayDate = formatter.string(from: self.now)
                    
                    let calendar = Calendar.current
                    let midnight = calendar.nextDate(after: self.now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)!
                    state.remainingSeconds = Int(midnight.timeIntervalSince(self.now))
                    
                    effects.append(
                        .run { send in
                            await send(.timerStarted)
                            for await _ in self.clock.timer(interval: .seconds(1)) {
                                await send(.tick)
                            }
                        }
                            .cancellable(id: CancelID.timer)
                    )
                }
                
                effects.append(.send(.fetchCards))
                
                return .merge(effects)
                
            case let .setColorPalette(colors):
                state.cardColors = colors
                return .none
                
            case .onDisappear:
                state.timerIsRunning = false
                return .cancel(id: CancelID.timer)
                
            case .timerStarted:
                return .none
                
            case .tick:
                if state.remainingSeconds > 0 {
                    state.remainingSeconds -= 1
                }
                return .none
            case .fetchCards:
                return .run { send in
                    do {
                        let userId = "3"
                        let publishedDate: String? = nil
                        
                        let cards = try await cardClient.fetchCards(userId, publishedDate)
                        await send(.setCards(cards))
                    } catch {
                        await send(.setCards([]))
                    }
                }
                
            case .setCards(let cards):
                state.cardData = cards
                if state.cardData.isEmpty {
                    return .none
                }
                if state.colorFlag == "A" {
                    let colors = Array(self.generateNewDailyColors(for: state.cardData).reversed())
                    return .send(.setColorPalette(colors))
                } else {
                    let fixedColors: [Color] = [ColorPalette.pointPurple200, ColorPalette.pointOrange400, ColorPalette.pointBlue300, ColorPalette.pointLemonYellow300, ColorPalette.pointPink300, ColorPalette.pointGreen300]
                    return .send(.setColorPalette(fixedColors))
                }
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
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
