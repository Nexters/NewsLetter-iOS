//
//  MarkdownClient.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import Foundation

import ComposableArchitecture

@DependencyClient
struct MarkdownClient {
    static let apiClient = MoyaAPIClient()

    /// 노출 콘텐츠의 마크다운 본문을 조회한다
    var fetchMarkdown: (_ exposureContentId: Int) async throws -> String
}

extension DependencyValues {
    var markdownClient: MarkdownClient {
        get { self[MarkdownClient.self] }
        set { self[MarkdownClient.self] = newValue }
    }
}

extension MarkdownClient: DependencyKey {
    static var liveValue: MarkdownClient = {
        MarkdownClient(
            fetchMarkdown: { exposureContentId in
                let response = try await apiClient.request(
                    MarkdownAPI.fetchMarkdown(exposureContentId: exposureContentId)
                )
                return try response.map(MarkdownResponseDTO.self)
                    .markdownContent
                    .removingSourceMetaLines()
            }
        )
    }()

    static var previewValue: MarkdownClient = {
        MarkdownClient(
            fetchMarkdown: { _ in
                """
                ## 프리뷰 마크다운

                프리뷰용 샘플 본문입니다.

                * **볼드 항목:** 본문 설명
                """
            }
        )
    }()

    static var testValue: MarkdownClient = previewValue
}

// MARK: - 본문 정제

private extension String {
    /// 본문 상단의 출처 메타 줄을 걷어낸다.
    ///
    /// 서버 본문은 `**출처:** 뉴스레터명 | **원본 아티클:** [원문 읽기](...)` 형태의 줄로 시작한다.
    /// 앱은 같은 정보를 상세 화면의 출처 행으로 따로 노출하므로 그대로 두면 중복이다.
    /// `**주요 키워드:**` 줄은 본문 정보라 남긴다.
    func removingSourceMetaLines() -> String {
        let droppedPrefixes = ["**출처:**", "**원본 아티클:**"]
        return components(separatedBy: "\n")
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return !droppedPrefixes.contains { trimmed.hasPrefix($0) }
            }
            .joined(separator: "\n")
    }
}
