//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    let colorFlag: String
    @State private var isPresentModal: Bool = false
    @State private var isPresentJobDetailBottomSheet: Bool = false
    @State private var isPresentNotificationPermissionBottomSheet: Bool = false
    @State private var isPresentToastMessage: Bool = false
    @State private var selectedIndex: Int?
    @State private var cardTapCount: Int = 0
    let cardTypes: [CardType] = [.one, .two, .three, .four, .five, .six]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                VStack {
                    Text("\(store.state.todayDate)\nToday’s Hot News")
                        .fontRangeLimited()
                        .font(Font.custom("Jalnan Gothic", size: 32))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.semanticColor.text_strong)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 44)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(store.state.formattedTime)
                        .fontRangeLimited()
                        .font(.body16_semiBold)
                        .foregroundColor(.semanticColor.state_negative_primary)
                        .padding(.top, 8)
                    
                    Spacer()

                    VStack(spacing: -35) {
                        ForEach(Array(store.state.cardData.enumerated()), id: \.offset) { index, item in
                            CardView(
                                cardType: cardTypes[index],
                                color: store.cardColors[index],
                                title: item.title,
                                category: item.topKeyword,
                                source: item.newsletterName,
                                onTap: {
                                    selectedIndex = index
                                    cardTapHandler()
                                }
                            )
                        }
                    }
                    .padding(.bottom, -20)
                }
                .ignoresSafeArea(edges: .bottom)
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
                    store.send(.onAppear(colorFlag: self.colorFlag))
                    print()
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
                
                if isPresentModal {
                    CarouselModalView(
                        cardData: store.cardData,
                        pointColors: store.cardColors,
                        isPresented: $isPresentModal,
                        currentPage: $selectedIndex,
                        firstLookHandler: { isPresentNotificationPermissionBottomSheet = true }
                    )
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut, value: isPresentModal)
        } destination: { store in
            switch store.case {
            case .detail(let store):
                DetailView(store: store)
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

