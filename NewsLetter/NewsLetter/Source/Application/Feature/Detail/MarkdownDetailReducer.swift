//
//  MarkdownDetailReducer.swift
//  NewsLetter
//
//  Created by Claude on 8/18/26.
//

import Foundation

import ComposableArchitecture

@Reducer
struct MarkdownDetailReducer {
    /// 마크다운 본문 로드 상태
    enum LoadState: Equatable {
        case loading
        case loaded(String)
        case failed
    }

    @ObservableState
    struct State: Equatable {
        let exposureContentId: Int
        var loadState: LoadState = .loading

        init(exposureContentId: Int, loadState: LoadState = .loading) {
            self.exposureContentId = exposureContentId
            self.loadState = loadState
        }
    }

    enum Action {
        case onAppear
        case markdownLoaded(String)
        case markdownLoadFailed
    }

    @Dependency(\.markdownClient) var markdownClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 이미 본문을 받아온 뒤 화면이 다시 나타나면 재요청하지 않는다
                guard state.loadState == .loading else { return .none }
                return .run { [exposureContentId = state.exposureContentId] send in
                    do {
                        let markdown = try await markdownClient.fetchMarkdown(exposureContentId)
                        await send(.markdownLoaded(markdown))
                    } catch {
                        // 어떤 콘텐츠의 마크다운이 비어있는지 확인할 수 있도록 id를 남긴다
                        print("❌ 마크다운 조회 실패 - exposureContentId: \(exposureContentId), error: \(error)")
                        await send(.markdownLoadFailed)
                    }
                }

            case .markdownLoaded(let markdown):
                state.loadState = .loaded(markdown)
                return .none

            case .markdownLoadFailed:
                state.loadState = .failed
                return .none
            }
        }
    }
}
