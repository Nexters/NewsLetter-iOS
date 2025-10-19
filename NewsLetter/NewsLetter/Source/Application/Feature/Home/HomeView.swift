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

    let colorFlag: String
    let mainDescFlag: String
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var showRefreshButton: Bool {
        guard let refreshDate = UserActionHistory.useRefreshDate else { return true }
        return DateCalculator.isToday(date: refreshDate) == false
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
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
                                        .resizable()
                                        .frame(width: 16, height: 16) // FIXME: 아이콘 컬러 disabled 대응 필요
                                    
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
                        }
                    }

                    Spacer()

                    if store.state.cardData.count > 0 {
                        Image("bg_drawers")
                            .resizable()
                            .frame(width: 600, height: UIDevice.isSmallScreen ? Device.height*0.75 : Device.height*0.65)
                            .padding(.bottom, Device.safeAreaInsets.bottom)
                        //                        .frame(width: 600, height: 526)
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
                            shouldMoveY: ((Device.height - 477) / 2) + 180 - cardPositionY(at: index),
                            onTap: {
                                selectedIndex = index
                                cardTapHandler()

                                GA.click_newsletter(title: item.title, listIndex: store.state.cardData.count-1-index)
                            },
                            isPresentModal: $isPresentModal,
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
                GA.pageview_main()

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
                    store.send(.onAppear(colorFlag: self.colorFlag))
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
    private func cardPositionY(at index: Int) -> CGFloat {
        if UIDevice.isSmallScreen {
            return Device.height - 430 + CGFloat(index * 80)
        } else if UIDevice.is13MiniScreen {
            return Device.height - 455 + CGFloat(index * 83)
        } else if UIDevice.isLargeScreen {
            return Device.height - 530 + CGFloat(index * 95)
        } else {
            return Device.height - 490 + CGFloat(index * 90)
        }
    }
    
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
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    },
             colorFlag: "A", mainDescFlag: "T")
}

