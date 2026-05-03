//
//  RecommendView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture
import FirebaseAnalytics

struct RecommendView: View {
    private enum Metric {
        static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
        static let scrollHorizontalMargin: CGFloat = (UIScreen.main.bounds.width - cardWidth) / 2
        static let indicatorSize: CGFloat = 8
        static let indicatorHilightedSize: CGFloat = 22
    }
    @Environment(\.scenePhase) private var scenePhase
    
    @Bindable var store: StoreOf<RecommendReducer>
    
    @Binding var selectedIndex: Int?
    
    @State private var cardTapCount: Int = 0
    @State private var scrolledID: Int?
    @State private var isJumping = false // 무한 스크롤을 위해 position 점프를 하고있는 중인지 여부
    
    // 배열 인덱스 → 실제 카드 인덱스 매핑
    // loopedCards: [3, 0, 1, 2, 3, 0] (stubCards 기준 인덱스)
    private var loopedCardIndices: [Int] {
        let count = store.cardData.count
        guard count > 0 else { return [] }
        return [count - 1] + Array(0..<count) + [0]
    }
    
    var showRefreshButton: Bool {
        guard let refreshDate = UserActionHistory.useRefreshDate else { return true }
        return DateCalculator.isToday(date: refreshDate) == false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            refreshButton
                .padding(.top, 12)
            cardCarousel
                .padding(.top, 80)
            indicator
                .padding(.top, 40)
            Spacer()
        }
        .animation(.easeInOut, value: store.isPresentModal)
        .animation(.smooth, value: scrolledID)
        .transition(.opacity)
        .onAppear {
            GA.pageview_main()
            
            store.send(.onAppear)
            
            if UserActionHistory.isFirstAppLaunch {
                UserActionHistory.isFirstAppLaunch = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    store.send(.delegate(.presentJobDetailBottomSheet(true)))
                }
            }
            
            DateCalculator.checkAndIncrementVisitStreak()
            
            guard UserActionHistory.streakCount >= 2 &&
                    UserActionHistory.isAlreadySetNotification == false &&
                    DateCalculator.isCanShowNotificationPermissionBottomSheet()
            else { return }
            store.send(.delegate(.presentNotificationPermissionBottomSheet(true)))
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.send(.onAppear)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(store.state.todayDate)
                .fontRangeLimited()
                .font(UIDevice.isSmallScreen || UIDevice.is13MiniScreen ? .jalnanGothicSE : .jalnanGothic)
                .multilineTextAlignment(.center)
                .foregroundColor(.semanticColor.text_strong)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, UIDevice.isSmallScreen ? 4 : 12)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("뉴스레터는 매일 새롭게 업데이트 돼요")
                .fontRangeLimited()
                .font(.body15_semiBold)
                .foregroundColor(.semanticColor.text_strong)
            
            HStack(spacing: 0) {
                Text("아래 뉴스는 ")
                    .font(.body15_medium)
                    .foregroundColor(.semanticColor.text_secondary)
                Text(store.state.formattedTime)
                    .fontRangeLimited()
                    .font(.body16_semiBold)
                    .foregroundColor(.semanticColor.state_negative_primary)
                Text(" 동안 볼 수 있어요")
                    .font(.body15_medium)
                    .foregroundColor(.semanticColor.text_secondary)
            }
        }
    }
    
    private var cardCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -80) {
                ForEach(Array(loopedCardIndices.enumerated()), id: \.offset) { position, cardIndex in
                    let data = store.cardData[cardIndex]
                    let props = RecommendCardCellProps(
                        title: data.title,
                        job: data.topKeyword,
                        source: data.newsletterName,
                        kind: .blog,
                        colorSet: store.cardColors[cardIndex]
                    )
                    RecommendCardCell(props: props)
                        .frame(width: Metric.cardWidth)
                        .scaleEffect(scrolledID == position ? 1 : 0.7)
                        .blur(radius: scrolledID == position ? 0 : 2)
                        .rotation3DEffect(
                            .degrees(cardRotationDegree(for: position)),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .zIndex(position == scrolledID ? 2 : 1)
                        .id(position)
                        .onTapGesture {
                            GA.click_newsletter(title: data.title, listIndex: position)
                            selectedIndex = cardIndex
                            cardTapHandler()
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, Metric.scrollHorizontalMargin, for: .scrollContent)
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .transaction { t in
            if isJumping {
                t.disablesAnimations = true
            }
        }
        .onAppear {
            if scrolledID == nil {
                scrolledID = 1
            }
        }
        .onChange(of: scrolledID) { _, newValue in
            guard let newValue else { return }
            let count = store.cardData.count
            guard count > 0 else { return }
            let lastIndex = count + 1
            
            if newValue == 0 {
                isJumping = true
                scrolledID = count
                DispatchQueue.main.async { isJumping = false }
            } else if newValue == lastIndex {
                isJumping = true
                scrolledID = 1
                DispatchQueue.main.async { isJumping = false }
            }
        }
    }
    
    private var indicator: some View {
        HStack(spacing: Metric.indicatorSize) {
            ForEach(0..<store.cardData.count, id: \.self) { index in
                let isFocused = index + 1 == scrolledID
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color.black : Color.gray.opacity(0.5))
                    .frame(
                        width: isFocused ? Metric.indicatorHilightedSize : Metric.indicatorSize,
                        height: Metric.indicatorSize
                    )
                    .animation(.easeInOut, value: scrolledID)
                    .onTapGesture {
                        scrolledID = index + 1
                    }
            }
        }
    }
    
    var refreshButton: some View {
        Button {
            store.send(.refreshButtonPressed)
        } label: {
            HStack(spacing: 4) {
                if store.isRefreshLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.semanticColor.text_secondary)
                        .frame(width: 16, height: 16)
                } else {
                    Image("icon-sync-mono")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(showRefreshButton ? .semanticColor.text_secondary : .semanticColor.text_disabled)
                }

                Text("새로고침 (\(showRefreshButton ? 0 : 1)/1)")
                    .font(.body14_semiBold)
                    .foregroundColor(showRefreshButton ? .semanticColor.text_secondary : .semanticColor.text_disabled)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(showRefreshButton ? .semanticColor.fill_primary : .clear)
            )
        }
        .disabled(!showRefreshButton || store.isRefreshLoading)
    }
    
    private func cardTapHandler() {
        if cardTapCount >= 3 {
            guard UserActionHistory.isAlreadyInputJobDetail == false &&
                    DateCalculator.isCanShowJobDetailBottomSheet()
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    store.isPresentModal = true
                    store.send(.delegate(.presentModal(true)))
                }
                return
            }
            store.send(.delegate(.presentJobDetailBottomSheet(true)))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                store.isPresentModal = true
                store.send(.delegate(.presentModal(true)))
            }
        }
        cardTapCount += 1
    }
    
    private func cardRotationDegree(for position: Int) -> Double {
        guard let scrolledID else { return 0 }
        let isPrevCard = position == scrolledID - 1
        let isNextCard = position == scrolledID + 1
        
        if isPrevCard {
            return 20
        }
        if isNextCard {
            return -20
        }
        return 0
    }
}

extension UIDevice {
    static var isSmallScreen: Bool {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width <= 320 || screenBounds.height <= 667
    }
    
    static var is13MiniScreen: Bool {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width <= 375 || screenBounds.height <= 736
    }
    
    static var isLargeScreen: Bool {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width >= 428
    }
}

#Preview {
    RecommendView(
        store: Store(initialState: RecommendReducer.State()) { RecommendReducer() },
        selectedIndex: .constant(nil),
    )
}
