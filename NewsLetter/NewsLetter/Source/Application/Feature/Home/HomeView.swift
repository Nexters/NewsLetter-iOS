
//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                HomeNavigationBar(
                    selectedSegment: $store.selectedSegment,
                    settingButtonTapHandler: {
                        store.send(.settingPressed)
                    }
                )
                switch store.selectedSegment {
                case .recommend:
                    RecommendView(
                        store: store.scope(state: \.recommendState, action: \.recommend),
                        selectedIndex: $store.selectedIndex
                    )
                case .explore:
                    ExploreView(
                        store: store.scope(state: \.exploreState, action: \.explore)
                    )
                }
            }
            .ignoresSafeArea()
            .overlay {
                if store.isPresentModal, let selectedIndex = store.selectedIndex {
                    SingleModalView(
                        isPresented: $store.isPresentModal,
                        index: selectedIndex,
                        cardData: store.recommendState.cardData[selectedIndex],
                        pointColor: store.recommendState.cardColors[selectedIndex].sub,
                        firstLookHandler: { store.isPresentNotificationPermissionBottomSheet = true }
                    )
                    .frame(width: Device.width)
                    .transition(.opacity)
                    .zIndex(Z.carouselModal)
                }
            }
            .overlay {
                if store.isPresentExploreCard, let (card, colorPaletteName) = store.exploreState.selectedCard {
                    ExploreCardModalView(
                        isPresented: $store.isPresentExploreCard,
                        cardData: card,
                        pointColor: colorPaletteName.color.toChangeColor(),
                    )
                    .frame(width: Device.width)
                    .transition(.opacity)
                    .zIndex(Z.carouselModal)
                }
            }
            .draggableBottomSheet(
                isShow: $store.isPresentJobDetailBottomSheet,
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
                isShow: $store.isPresentNotificationPermissionBottomSheet,
                dismissHandler: { UserActionHistory.deniedDateWhenSetNotification = Date() }
            ) {
                NotificationPermissionBottomSheet(
                    isPresented: $store.isPresentNotificationPermissionBottomSheet,
                    successHandler: {
                        store.send(.recommend(.registerUser))
                        store.isPresentToastMessage = true
                    }
                )
            }
            .draggableBottomSheet(
                isShow: $store.isPresentNewsletterReportBottomSheet,
                dismissHandler: {},
                cornerRadius: 24,
                showHandleBar: false
            ) {
                NewsletterReportBottomSheet(
                    isPresented: $store.isPresentNewsletterReportBottomSheet,
                    submitHandler: { dto in
                        store.send(.submitNewsletterReport(dto))
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .toastMessage(
                isPresented: $store.isPresentToastMessage,
                text: "뉴스레터 알림이 신청되었어요",
                bottomPadding: 0
            )
            .reportSuccessToast(
                isPresented: $store.isPresentReportSuccessToast,
                topPadding: (UIDevice.isSmallScreen ? 24 : 50) + (UIDevice.isSmallScreen ? 36 : 48) + 8
            )
            .animation(.easeInOut, value: store.isPresentModal)
            .animation(.easeInOut, value: store.isPresentExploreCard)
        } destination: { store in
            switch store.case {
            case .setting(let store):
                SettingView(store: store)
            }
        }
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
        store.send(.recommend(.updateUser(requestDTO)))
        store.send(.recommend(.onAppear))
        store.isPresentJobDetailBottomSheet = false
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    })
}
