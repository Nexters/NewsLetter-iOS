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
    let colorFlag: String
    @State private var isPresentModal: Bool = false
    @State private var isPresentJobDetailBottomSheet: Bool = false
    @State private var isPresentNotificationPermissionBottomSheet: Bool = false
    @State private var isPresentToastMessage: Bool = false
    @State private var selectedIndex: Int?
    @State private var cardTapCount: Int = 0
    @State private var pulseOffsets: [Int: CGFloat] = [:]
    @State private var didAnimateIndex: Set<Int> = []
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var body: some View {
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
                    .frame(width: Device.width, height: 48)
                    .padding(.top, 50)

                    VStack(spacing: 8) {
                        Text("\(store.state.todayDate)\nToday’s Hot News")
                            .fontRangeLimited()
                            .font(.jalnanGothic)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.semanticColor.text_strong)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 12)
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

                    Image("bg_drawers")
                        .resizable()
                        .frame(width: 600, height: 526)
                }

                Group {
                    ForEach(Array(store.state.cardData.enumerated()), id: \.offset) { index, item in
                        CardView(
                            cardType: cardTypes[index],
                            color: store.cardColors[index],
                            title: item.title,
                            category: item.topKeyword,
                            source: item.newsletterName,
                            shouldMoveY: ((Device.height - 477) / 2) + 180 - (Device.height - 450 + CGFloat(index * 80)),
                            /// 477 은 CarouselCard 부터 하단 X 버튼 까지의 높이
                            /// 200 은 조정값 (position 이 뷰의 중앙을 표현하는 값인 거 같아서 뷰의 높이 절반을 추가해주는 거)
                            onTap: {
                                selectedIndex = index
                                cardTapHandler()

                                let dataString = (try? JSONSerialization.data(withJSONObject: ["list_index": store.state.cardData.count-1-index]))
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
                            isPresentModal: $isPresentModal,
                        )
                        .position(x: Device.width / 2, y: Device.height - 450 + CGFloat(index * 80))
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
                    .zIndex(20)
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
                Analytics.logEvent(AnalyticsEventScreenView,
               parameters: [
                AnalyticsParameterScreenName: "main"
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
        isPresentJobDetailBottomSheet = false
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    },
             colorFlag: "A")
}

