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
    
    var showRefreshButton: Bool {
        guard let refreshDate = UserActionHistory.useRefreshDate else { return true }
        return DateCalculator.isToday(date: refreshDate) == false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 8)
            cardCarousel
                .padding(.top, UIDevice.isLargeScreen ? 40 : 16)
            indicator
                .padding(.top, 16)
            refreshButton
                .padding(.top, 36)
            Spacer()
        }
        .animation(.easeInOut, value: store.isPresentModal)
        .animation(.smooth, value: scrolledID)
        .transition(.opacity)
        .background(ColorPalette.gray50)
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
        VStack(spacing: 0) {
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
                .font(.body15_medium)
                .foregroundColor(.semanticColor.text_tertiary)
                .padding(.top, 12)

            Text(store.state.formattedTime)
                .fontRangeLimited()
                .font(.body16_bold)
                .foregroundColor(.semanticColor.state_negative_primary)
                .padding(.top, 4)
        }
    }
    
    private var cardCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -80) {
                ForEach(Array(store.cardData.enumerated()), id: \.offset) { index, data in
                    let props = RecommendCardCellProps(
                        title: data.title,
                        job: data.topKeyword,
                        source: data.newsletterName,
                        imageURL: data.imageURL,
                        isTrendingCard: index == 0,
                        kind: data.kind,
                        colorSet: store.cardColors[index]
                    )
                    RecommendCardCell(props: props)
                        .frame(width: Metric.cardWidth)
                        .scaleEffect(scrolledID == index ? 1 : 0.7)
                        .blur(radius: scrolledID == index ? 0 : 2)
                        .rotation3DEffect(
                            .degrees(cardRotationDegree(for: index)),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .zIndex(index == scrolledID ? 2 : 1)
                        .id(index)
                        .onTapGesture {
                            guard scrolledID == index else {
                                scrolledID = index
                                return
                            }
                            GA.click_newsletter(title: data.title, listIndex: index)
                            selectedIndex = index
                            cardTapHandler()
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, Metric.scrollHorizontalMargin, for: .scrollContent)
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .onAppear {
            if scrolledID == nil {
                scrolledID = 0
            }
        }
    }
    
    private var indicator: some View {
        HStack(spacing: Metric.indicatorSize) {
            ForEach(0..<store.cardData.count, id: \.self) { index in
                let isFocused = index == scrolledID
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color.black : Color.gray.opacity(0.5))
                    .frame(
                        width: isFocused ? Metric.indicatorHilightedSize : Metric.indicatorSize,
                        height: Metric.indicatorSize
                    )
                    .animation(.easeInOut, value: scrolledID)
                    .onTapGesture {
                        scrolledID = index
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
