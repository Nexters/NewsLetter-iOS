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
    typealias Flags = (colorFlag: String, mainDescFlag: String)
    
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
        var colorFlag: String = ""
        var mainDescFlag: String = ""
        var isPresentModal: Bool = false
        var isPresentExploreCard: Bool = false
        var isPresentNotificationPermissionBottomSheet: Bool = false
        var isPresentJobDetailBottomSheet: Bool = false
        var isPresentToastMessage: Bool = false
        var selectedIndex: Int?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case recommend(RecommendReducer.Action)
        case explore(ExploreReducer.Action)
        case settingPressed
        case setFlags(Flags)
    }
    
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
            case .recommend(.delegate(.presentJobDetailBottomSheet)):
                state.isPresentJobDetailBottomSheet = true
                return .none
            // ExploreReducer의 delegate 액션 처리
            case .explore(.delegate(.presentExploreCard)):
                state.isPresentExploreCard = true
                return .none
            case .settingPressed:
                state.path.append(.setting(SettingReducer.State()))
                return .none
            case .setFlags(let flags):
                state.colorFlag = flags.colorFlag
                state.mainDescFlag = flags.mainDescFlag
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
