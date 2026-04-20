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
    @Bindable var store: StoreOf<RecommendReducer>
    @Binding var selectedIndex: Int?
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var cardTapCount: Int = 0
    @State private var pulseOffsets: [Int: CGFloat] = [:]
    @State private var didAnimateSlot: Set<Int> = []
    @State private var selectedSegment: SegmentView.SegmentType = .recommend
    
    @State private var start: Int = 0
    @State private var scrollAccum: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State private var lastDragTranslation: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var cardHeights: [CGFloat] = []
    @State private var isCardAnimating: Bool = false
    
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var showRefreshButton: Bool {
        guard let refreshDate = UserActionHistory.useRefreshDate else { return true }
        return DateCalculator.isToday(date: refreshDate) == false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer()
                
                if store.state.cardData.count > 0 {
                    Image("bg_drawers")
                        .resizable()
                        .frame(width: 600, height: UIDevice.isSmallScreen ? Device.height * 0.75 : Device.height * 0.65)
                        .padding(.bottom, Device.safeAreaInsets.bottom)
                }
            }
            .allowsHitTesting(false)
            
            cardsStack
                .padding(.bottom, -20)
                .frame(width: Device.width)
                .contentShape(Rectangle())
                .simultaneousGesture(cardScrollGesture)
            
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
                
                Button {
                    store.send(.refreshButtonPressed)
                } label: {
                    HStack(spacing: 4) {
                        Image("icon-sync-mono")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(showRefreshButton ? .semanticColor.text_secondary : .semanticColor.text_disabled)
                        
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
                .disabled(!showRefreshButton)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .animation(.easeInOut, value: store.isPresentModal)
        .ignoresSafeArea(edges: .all)
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
            
            initializeCardHeights()
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
    
    @ViewBuilder
    private var cardsStack: some View {
        let count = min(cardTypes.count, store.state.cardData.count)
        if count == 0 {
            EmptyView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    if progress > 0, count > 0 {
                        let dataIndex = feedIndex(for: count - 1, count: count)
                        phantomCardView(
                            dataIndex: dataIndex,
                            targetSlot: 0,
                            positionY: cardPositionY(at: 1) - progress * cardStep - 10,
                            zIndex: -1
                        )
                    }
                    
                    ForEach(0..<count, id: \.self) { slot in
                        let dataIndex = feedIndex(for: slot, count: count)
                        let item = store.state.cardData[dataIndex]
                        
                        let currentDepth = CGFloat(slot) + progress
                        let style = interpolatedStyle(depth: currentDepth)
                        
                        let translationY = calculateTranslationY(for: slot, count: count)
                        
                        CardView(
                            style: style,
                            color: store.cardColors[dataIndex],
                            title: item.title,
                            category: item.topKeyword,
                            source: item.newsletterName,
                            shouldMoveY: ((Device.height - 477) / 2) + 180 - cardPositionY(at: slot) - 90,
                            onTap: {
                                guard !isDragging else { return }
                                selectedIndex = dataIndex
                                cardTapHandler()
                                GA.click_newsletter(title: item.title, listIndex: count - 1 - dataIndex)
                            },
                            onTapBegan: {
                                lockCardScrollForTapAnimation()
                            },
                            isPresentModal: $store.isPresentModal
                        )
                        .position(
                            x: Device.width / 2,
                            y: cardPositionY(at: slot) + translationY
                        )
                        .offset(y: pulseOffsets[slot] ?? 0)
                        .zIndex(Double(slot))
                        .onAppear {
                            guard !didAnimateSlot.contains(slot) else { return }
                            didAnimateSlot.insert(slot)
                            
                            let playOrder = (count - 1) - slot
                            let delayMs = playOrder * 150
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayMs)) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    pulseOffsets[slot] = -5
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        pulseOffsets[slot] = 0
                                    }
                                }
                            }
                        }
                    }
                    
                    if progress < 0, count > 0 {
                        let lastSlot = count - 1
                        let dataIndex = feedIndex(for: 0, count: count)
                        phantomCardView(
                            dataIndex: dataIndex,
                            targetSlot: lastSlot,
                            positionY: cardPositionY(at: lastSlot) + cardStep + progress * cardStep + 10,
                            zIndex: 5
                        )
                    }
                }
            }
        }
    }
    
    private var cardScrollGesture: AnyGesture<DragGesture.Value> {
        if isScrollLocked {
            return AnyGesture(DragGesture(minimumDistance: .infinity))
        }
        
        return AnyGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    isDragging = true
                    let delta = value.translation.height - lastDragTranslation
                    lastDragTranslation = value.translation.height
                    scrollAccum += delta
                    
                    let step = cardStep
                    let count = min(cardTypes.count, store.state.cardData.count)
                    guard count > 0 else { return }
                    
                    while scrollAccum >= step {
                        start = (start + 1) % count
                        scrollAccum -= step
                    }
                    
                    while scrollAccum <= -step {
                        start = (start - 1 + count) % count
                        scrollAccum += step
                    }
                    
                    progress = scrollAccum / step
                }
                .onEnded { _ in
                    lastDragTranslation = 0
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scrollAccum = 0
                        progress = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isDragging = false
                    }
                }
        )
    }
    
    private var isScrollLocked: Bool {
        isCardAnimating || store.isPresentModal
    }
    
    private func lockCardScrollForTapAnimation() {
        guard isCardAnimating == false else { return }
        isCardAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CardView.tapAnimationTotalDuration) {
            isCardAnimating = false
        }
    }
    
    @ViewBuilder
    private func phantomCardView(
        dataIndex: Int,
        targetSlot: Int,
        positionY: CGFloat,
        zIndex: Double
    ) -> some View {
        let item = store.state.cardData[dataIndex]
        let style = interpolatedStyle(depth: CGFloat(targetSlot))
        
        CardView(
            style: style,
            color: store.cardColors[dataIndex],
            title: item.title,
            category: item.topKeyword,
            source: item.newsletterName,
            shouldMoveY: ((Device.height - 477) / 2) + 180 - cardPositionY(at: targetSlot) - 90,
            onTap: {
                guard !isDragging else { return }
                selectedIndex = dataIndex
                cardTapHandler()
            },
            onTapBegan: {
                lockCardScrollForTapAnimation()
            },
            isPresentModal: $store.isPresentModal
        )
        .position(x: Device.width / 2, y: positionY)
        .zIndex(zIndex)
    }
    
    private func initializeCardHeights() {
        let count = min(cardTypes.count, store.state.cardData.count)
        guard count > 0 else { return }
        
        cardHeights = (0..<count).map { index in
            if index == 0 { return 0 }
            return cardPositionY(at: index) - cardPositionY(at: index - 1)
        }
    }
    
    private func getCardHeightDiff(at index: Int) -> CGFloat {
        guard index >= 0 && index < cardHeights.count else { return cardStep }
        return cardHeights[index]
    }
    
    private func calculateTranslationY(for slot: Int, count: Int) -> CGFloat {
        if progress < 0 {
            if slot == 0 {
                return -progress * 20
            } else {
                return progress * cardStep
            }
        } else {
            if slot == count - 1 {
                return progress * cardStep
            } else {
                let dataIndex = feedIndex(for: slot, count: count)
                let nextIndex = min(dataIndex + 1, count - 1)
                return getCardHeightDiff(at: nextIndex) * progress
            }
        }
    }
    
    private func feedIndex(for slot: Int, count: Int) -> Int {
        (slot - start + count) % count
    }
    
    private var cardStep: CGFloat {
        if UIDevice.isSmallScreen { return 80 }
        if UIDevice.is13MiniScreen { return 83 }
        if UIDevice.isLargeScreen { return 95 }
        return 90
    }
    
    private func cardPositionY(at index: Int) -> CGFloat {
        if UIDevice.isSmallScreen {
            return Device.height - 430 + CGFloat(index * 80) - 100
        } else if UIDevice.is13MiniScreen {
            return Device.height - 455 + CGFloat(index * 83) - 100
        } else if UIDevice.isLargeScreen {
            return Device.height - 530 + CGFloat(index * 95) - 100
        } else {
            return Device.height - 490 + CGFloat(index * 90) - 100
        }
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
