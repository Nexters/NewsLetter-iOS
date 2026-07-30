//
//  HomeReducer.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import Foundation
import Combine

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @Reducer
    enum Path {
        case setting(SettingReducer)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var recommendState = RecommendReducer.State()
        var exploreState = ExploreReducer.State()
        var selectedSegment: SegmentView.SegmentType = .recommend
        var isPresentModal: Bool = false
        var isPresentExploreCard: Bool = false
        var isPresentNotificationPermissionBottomSheet: Bool = false
        var isPresentOnboardingJobBottomSheet: Bool = false
        var isPresentNewsletterReportBottomSheet: Bool = false
        var isPresentToastMessage: Bool = false
        var isPresentJobChangeToastMessage: Bool = false
        var isPresentReportSuccessToast: Bool = false
        var selectedIndex: Int?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case recommend(RecommendReducer.Action)
        case explore(ExploreReducer.Action)
        case settingPressed
        case submitNewsletterReport(NewsletterReportRequestDTO)
        case setIsPresentReportSuccessToast(Bool)
    }
    
    @Dependency(\.newsletterReportClient) var newsletterReportClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.recommendState, action: \.recommend) {
            RecommendReducer()
        }
        
        Scope(state: \.exploreState, action: \.explore) {
            ExploreReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .binding(\.isPresentModal):
                if !state.isPresentModal {
                    return .send(.recommend(.setIsPresentModal(false)))
                }
                return .none
            // RecommendReducer의 delegate 액션 처리
            case .recommend(.delegate(.presentModal)):
                state.isPresentModal = true
                return .none
            case .recommend(.delegate(.presentNotificationPermissionBottomSheet)):
                state.isPresentNotificationPermissionBottomSheet = true
                return .none
            case .recommend(.delegate(.presentOnboardingJobBottomSheet)):
                state.isPresentOnboardingJobBottomSheet = true
                return .none
            // ExploreReducer의 delegate 액션 처리
            case .explore(.delegate(.presentExploreCard)):
                state.isPresentExploreCard = true
                return .none
            case .explore(.delegate(.reportNewsletterButtonTapped)):
                state.isPresentNewsletterReportBottomSheet = true
                return .none
            case .settingPressed:
                state.path.append(.setting(SettingReducer.State()))
                return .none
            // 설정 화면에서 직군/경력 정보가 갱신되면 추천 컨텐츠를 새로 불러옵니다.
            case .path(.element(id: _, action: .setting(.delegate(.categoryUpdated)))):
                state.recommendState.isCardLoading = true
                return .send(.recommend(.fetchCards))
            case .submitNewsletterReport(let dto):
                return .run { send in
                    do {
                        try await newsletterReportClient.submitReport(dto)
                        await send(.setIsPresentReportSuccessToast(true))
                    } catch {
                        print("[HomeReducer] submitNewsletterReport 에러발생: \(error.localizedDescription)")
                    }
                }
            case .setIsPresentReportSuccessToast(let value):
                state.isPresentReportSuccessToast = value
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
