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
    @State private var didAnimateIndex: Set<Int> = []
    @State private var selectedSegment: SegmentView.SegmentType = .recommend
    
    let colorFlag: String
    let mainDescFlag: String
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var showRefreshButton: Bool {
        guard let refreshDate = UserActionHistory.useRefreshDate else { return true }
        return DateCalculator.isToday(date: refreshDate) == false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text((mainDescFlag == "T") ? "\(store.state.todayDate)" : "\(store.state.todayDate)\nToday's Hot News")
                        .fontRangeLimited()
                        .font(UIDevice.isSmallScreen || UIDevice.is13MiniScreen ? .jalnanGothicSE : .jalnanGothic)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.semanticColor.text_strong)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, UIDevice.isSmallScreen ? 4 : 12)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if (mainDescFlag == "T") {
                        Text("뉴스레터는 매일 새롭게 업데이트 돼요")
                            .fontRangeLimited()
                            .font(.body15_semiBold)
                            .foregroundColor(.semanticColor.text_strong)
                    }
                    
                    HStack(spacing: 0) {
                        if (mainDescFlag == "T") {
                            Text("아래 뉴스는 ")
                                .font(.body15_medium)
                                .foregroundColor(.semanticColor.text_secondary)
                        }
                        Text(store.state.formattedTime)
                            .fontRangeLimited()
                            .font(.body16_semiBold)
                            .foregroundColor(.semanticColor.state_negative_primary)
                        Text(" 동안 볼 수 있어요")
                            .font(.body15_medium)
                            .foregroundColor(.semanticColor.text_secondary)
                    }
                    
                    if (mainDescFlag == "T") {
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
                }
                
                Spacer()
                
                if store.state.cardData.count > 0 {
                    Image("bg_drawers")
                        .resizable()
                        .frame(width: 600, height: UIDevice.isSmallScreen ? Device.height*0.75 : Device.height*0.65)
                        .padding(.bottom, Device.safeAreaInsets.bottom)
                }
            }
            
            Group {
                ForEach(Array(store.state.cardData.enumerated()), id: \.offset) { index, item in
                    CardView(
                        cardType: cardTypes[index],
                        color: store.cardColors[index],
                        title: item.title,
                        category: item.topKeyword,
                        source: item.newsletterName,
                        /// 477 은 CarouselCard 부터 하단 X 버튼 까지의 높이
                        /// 180 은 조정값
                        shouldMoveY: ((Device.height - 477) / 2) + 180 - cardPositionY(at: index) - 90,
                        onTap: {
                            selectedIndex = index
                            cardTapHandler()
                            
                            GA.click_newsletter(title: item.title, listIndex: store.state.cardData.count-1-index)
                        },
                        isPresentModal: $store.isPresentModal,
                    )
                    .position(x: Device.width / 2, y: cardPositionY(at: index)) /// index 에 따라 세부 조정값 필요
                    .offset(y: pulseOffsets[index] ?? 0)
                    .onAppear {
                        guard !didAnimateIndex.contains(index) else { return }
                        didAnimateIndex.insert(index)
                        
                        let playOrder = (store.state.cardData.count - 1) - index
                        let delayMs = playOrder * 150
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayMs)) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                pulseOffsets[index] = -5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    pulseOffsets[index] = 0
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, -20)
            .frame(width: Device.width)
        }
        .animation(.easeInOut, value: store.isPresentModal)
        .ignoresSafeArea(edges: .all)
        .transition(.opacity)
        .onAppear {
            GA.pageview_main()
            
            store.send(.onAppear(colorFlag: self.colorFlag))
            
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
                store.send(.onAppear(colorFlag: self.colorFlag))
            }
        }
        
    }
    
    // MARK: - Methods
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
        colorFlag: "A",
        mainDescFlag: "T"
    )
}

