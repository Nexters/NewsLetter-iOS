//
//  NewsletterReportClient.swift
//  NewsLetter
//

import ComposableArchitecture
import Moya

@DependencyClient
struct NewsletterReportClient {
    static let apiClient = MoyaAPIClient()

    var submitReport: (NewsletterReportRequestDTO) async throws -> Void
}

extension DependencyValues {
    var newsletterReportClient: NewsletterReportClient {
        get { self[NewsletterReportClient.self] }
        set { self[NewsletterReportClient.self] = newValue }
    }
}

extension NewsletterReportClient: DependencyKey {
    static var liveValue: NewsletterReportClient = {
        return NewsletterReportClient(
            submitReport: { requestDTO in
                _ = try await apiClient.request(NewsletterReportAPI.submitReport(requestDTO))
            }
        )
    }()

    static var previewValue: NewsletterReportClient = {
        return NewsletterReportClient(
            submitReport: { _ in }
        )
    }()

    static var testValue: NewsletterReportClient = previewValue
}
