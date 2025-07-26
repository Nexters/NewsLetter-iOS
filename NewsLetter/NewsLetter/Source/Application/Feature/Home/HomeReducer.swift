//
//  HomeReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture
import Foundation

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

        var cardData: [(CardType, String, String, String)] = [
            (.one,   "메가커피 컵빙수의 품절 대란", "Kotlin", "안드로이드 위클리"),
            (.two,   "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", "Swift", "iOS 뉴스레터"),
            (.three, "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", "기업정보", "전자신문"),
            (.four,  "오늘의 날씨는?", "Weather", "기상청"),
            (.five,  "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔", "부동산", "매일경제"),
            (.six,   "일이삼사오육칠팔구십일이삼사오육칠", "정치", "정치뉴스")
        ]
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case onDisappear
        case tick
        case timerStarted
    }

    private enum CancelID { case timer }

    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case .path(_):
                return .none
            case .onAppear:
                if state.timerIsRunning { return .none }
                state.timerIsRunning = true

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                state.todayDate = formatter.string(from: Date())

                let now = Date()
                let calendar = Calendar.current
                let midnight = calendar.nextDate(
                    after: now,
                    matching: DateComponents(hour: 0, minute: 0, second: 0),
                    matchingPolicy: .nextTime
                )!
                state.remainingSeconds = Int(midnight.timeIntervalSince(now))

                return .run { send in
                    await send(.timerStarted)
                    for await _ in self.clock.timer(interval: Duration.seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: CancelID.timer)

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
            }
        }
        .forEach(\.path, action: \.path)
    }
}
