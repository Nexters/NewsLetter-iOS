//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI
import ComposableArchitecture
import FirebaseAnalytics

struct HomeView: View {
    private enum Metric {
        static let cardSpacing: CGFloat = 90
        static let stackOriginY: CGFloat = 500
        static let carouselHeight: CGFloat = 477
        static let adjustY: CGFloat = 180
    }

    @Bindable var store: StoreOf<HomeReducer>
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPresentModal: Bool = false
    @State private var isPresentJobDetailBottomSheet: Bool = false
    @State private var isPresentNotificationPermissionBottomSheet: Bool = false
    @State private var isPresentToastMessage: Bool = false
    @State private var selectedIndex: Int?
    @State private var cardTapCount: Int = 0
    @State private var pulseOffsets: [Int: CGFloat] = [:]
    @State private var didAnimateIndex: Set<Int> = []

    /// 카드 스크롤  Animation 관련 변수
    @State private var stackProgress: CGFloat = 0
    @State private var stackDirection: CardStackDirection? = nil
    @Namespace private var cardNS
    
    private func targetIndex(for index: Int, total: Int, direction: CardStackDirection?) -> Int {
        guard let direction else { return index }
        switch direction {
        case .up:   return index == 0 ? (total - 1) : (index - 1)
        case .down: return index == total - 1 ? 0 : (index + 1)
        }
    }
    
    let colorFlag: String
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var body: some View {
        let cardIDs: [String] = store.state.cardData.map { $0.contentURL }
        
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottom) {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            store.send(.settingPressed)
                        } label: {
                            Image("setting_icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .padding(.trailing, 8)
                        }
                    }
                    .frame(width: Device.width, height: UIDevice.isSmallScreen ? 36 : 48)
                    .padding(.top, UIDevice.isSmallScreen ? 24 : 50)
                    
                    VStack(spacing: 8) {
                        Text("\(store.state.todayDate)\nToday’s Hot News")
                            .fontRangeLimited()
                            .font(UIDevice.isSmallScreen ? .jalnanGothicSE : .jalnanGothic)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.semanticColor.text_strong)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, UIDevice.isSmallScreen ? 4 : 12)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 0) {
                            Text(store.state.formattedTime)
                                .fontRangeLimited()
                                .font(.body16_semiBold)
                                .foregroundColor(.semanticColor.state_negative_primary)
                            Text(" 동안 볼 수 있어요")
                                .font(.body15_medium)
                                .foregroundColor(.semanticColor.text_secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if store.state.cardData.count > 0 {
                        Image("bg_drawers")
                            .resizable()
                            .frame(width: 600, height: Device.height * 0.7)
                    }
                }

                let totalCount: Int = store.state.cardData.count

                Group {
                    ForEach(Array(store.state.cardData.enumerated()), id: \.element.contentURL) { pair in

                        let index: Int = pair.offset
                        let item = pair.element

                        let baseY: CGFloat = Device.height - Metric.stackOriginY + CGFloat(index) * Metric.cardSpacing
                        let shouldMoveY: CGFloat = ((Device.height - Metric.carouselHeight) / 2) + Metric.adjustY - baseY
                        let pulseY: CGFloat = pulseOffsets[index] ?? 0

                        let toIdx: Int = targetIndex(for: index, total: totalCount, direction: stackDirection)
                        let targetY: CGFloat = Device.height - Metric.stackOriginY + CGFloat(toIdx) * Metric.cardSpacing
                        let isWrapDown: Bool = (stackDirection == .down && index == totalCount - 1 && toIdx == 0)
                        let previewDeltaY: CGFloat = isWrapDown ? 0 : ((stackDirection == nil) ? 0 : (targetY - baseY) * stackProgress)
                        let fromType: CardType = cardTypes[index]
                        let toType: CardType = isWrapDown ? .one : cardTypes[toIdx]

                        CardView(
                            cardType: cardTypes[index],
                            color: store.cardColors[index],
                            title: item.title,
                            category: item.topKeyword,
                            source: item.newsletterName,
                            shouldMoveY: shouldMoveY,
                            onTap: {
                                selectedIndex = index
                                cardTapHandler()

                                let listIndex = totalCount - 1 - index
                                let dataString = (try? JSONSerialization.data(withJSONObject: ["list_index": listIndex]))
                                    .flatMap { String(data: $0, encoding: .utf8) }

                                Analytics.logEvent("click_newsletter", parameters: [
                                    "category": "click",
                                    "navigation": "main",
                                    "object_section": "newsletter_list",
                                    "object_type": "newsletter",
                                    "object_id": item.title,
                                    "data": dataString ?? ""
                                ])
                            },
                            isPresentModal: $isPresentModal
                        )
                        .cardTypeScaleAppearance(
                            id: item.contentURL,
                            from: fromType,
                            to: toType,
                            progress: stackProgress,
                            namespace: cardNS
                        )
                        .position(x: Device.width / 2, y: baseY)
                        .offset(y: pulseY + previewDeltaY)
                        .onAppear {
                            guard !didAnimateIndex.contains(index) else { return }
                            didAnimateIndex.insert(index)
                            let playOrder: Int = (totalCount - 1) - index
                            let delayMs: Int = playOrder * 150
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayMs)) {
                                withAnimation(.easeInOut(duration: 0.2)) { pulseOffsets[index] = -5 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                    withAnimation(.easeInOut(duration: 0.1)) { pulseOffsets[index] = 0 }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, -20)
                .frame(width: Device.width)
                
                if isPresentModal {
                    CarouselModalView(
                        cardData: store.cardData,
                        pointColors: store.cardColors,
                        isPresented: $isPresentModal,
                        currentPage: $selectedIndex,
                        firstLookHandler: { isPresentNotificationPermissionBottomSheet = true }
                    )
                    .frame(width: Device.width)
                    .transition(.opacity)
                    .zIndex(Z.carouselModal)
                }
            }
            .cardStackDragGesture(
                trigger: 90,
                maxStepsPerFling: 3,
                interStepDelay: 0.06,
                onProgress: { (prog: CGFloat, dir: CardStackDirection?) in
                    withAnimation(.interactiveSpring(response: 0.40, dampingFraction: 0.9)) {
                        stackProgress  = prog   
                        stackDirection = dir
                    }
                },
                onRotateDown: { store.send(.rotateBottomToTop) },
                onRotateUp:   { store.send(.rotateTopToBottom) }
            )
            .animation(CardStackAnimator.rotation, value: cardIDs)
            .animation(.easeInOut, value: isPresentModal)
            .ignoresSafeArea(edges: .all)
            .transition(.opacity)
            .draggableBottomSheet(
                isShow: $isPresentJobDetailBottomSheet,
                dismissHandler: { UserActionHistory.deniedDateWhenInputJobDetail = Date() }
            ) {
                JobDetailBottomSheet { selectedJobCategory, selectedCareer in
                    jobDetailBottomSheetConfirmHandler(
                        selectedJobCategory: selectedJobCategory,
                        selectedCareer: selectedCareer
                    )
                }
            }
            .draggableBottomSheet(
                isShow: $isPresentNotificationPermissionBottomSheet,
                dismissHandler: { UserActionHistory.deniedDateWhenSetNotification = Date() }
            ) {
                NotificationPermissionBottomSheet(
                    isPresented: $isPresentNotificationPermissionBottomSheet,
                    successHandler: {
                        store.send(.registerUser)
                        isPresentToastMessage = true
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .toastMessage(
                isPresented: $isPresentToastMessage,
                text: "뉴스레터 알림이 신청되었어요",
                bottomPadding: 0
            )
            .onAppear {
                Analytics.logEvent("pageview_main", parameters: [
                    "category": "pageview",
                    "navigation": "main"
                ])
                
                store.send(.onAppear(colorFlag: self.colorFlag))
                
                if UserActionHistory.isFirstAppLaunch {
                    UserActionHistory.isFirstAppLaunch = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresentJobDetailBottomSheet = true
                    }
                }
                
                DateCalculator.checkAndIncrementVisitStreak()
                
                guard UserActionHistory.streakCount >= 2 &&
                        UserActionHistory.isAlreadySetNotification == false &&
                        DateCalculator.isCanShowNotificationPermissionBottomSheet()
                else { return }
                
                isPresentNotificationPermissionBottomSheet = true
            }
            .onDisappear {
                store.send(.onDisappear)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    store.send(.startTimer)
                }
            }
        } destination: { store in
            switch store.case {
            case .setting(let store):
                SettingView(store: store)
            }
        }
    }
    
    // MARK: - Methods
    
    private func cardTapHandler() {
        if cardTapCount >= 3 {
            guard UserActionHistory.isAlreadyInputJobDetail == false &&
                    DateCalculator.isCanShowJobDetailBottomSheet()
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isPresentModal = true
                }
                return
            }
            
            isPresentJobDetailBottomSheet = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isPresentModal = true
            }
        }
        cardTapCount += 1
    }
    
    private func jobDetailBottomSheetConfirmHandler(
        selectedJobCategory: Set<Int>,
        selectedCareer: Int
    ) {
        let preferences = selectedJobCategory.map { Preference.allCases[$0] }
        let workingExperience = WorkingExperience.allCases[selectedCareer]
        let requestDTO = UserUpdateRequestDTO(
            preferences: preferences,
            workingExperience: workingExperience
        )
        store.send(.updateUser(requestDTO))
        store.send(.onAppear(colorFlag: self.colorFlag))
        isPresentJobDetailBottomSheet = false
    }
}

extension UIDevice {
    static var isSmallScreen: Bool {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width <= 320 || screenBounds.height <= 667
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeReducer.State()) { HomeReducer() },
        colorFlag: "A"
    )
}

