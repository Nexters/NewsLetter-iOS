//
//  CardClient.swift
//  NewsLetter
//
//  Created by 이조은 on 8/1/25.
//

import Combine

import ComposableArchitecture
import Moya

@DependencyClient
struct CardClient {
    static let apiClient = MoyaAPIClient()

    var fetchCards: (String, String?) async throws -> [Card] // FIXME: RequestDTO 모델로 분리
    var fetchExploreCards: (ExploreCardRequestDTO) async throws -> ExploreCardResponse
    var refreshCards: (String) async throws -> Void // FIXME: RequestDTO 모델로 분리
    var fetchOGShareURL: (OGShareURLRequestDTO) -> String = { _ in "" }
}

extension DependencyValues {
    var cardClient: CardClient {
        get { self[CardClient.self] }
        set { self[CardClient.self] = newValue }
    }
}

extension CardClient: DependencyKey {
    static var liveValue: CardClient = {
            return CardClient(
                fetchCards: { userId, publishedDate in
                    let response = try await apiClient.request(CardAPI.fetchCards(userId: userId, publishedDate: publishedDate))

                    let cardResponse = try response.map(CardResponseDTO.self)
                    let cards = cardResponse.cards.map { cardDTO in
                        Card(
                            id: cardDTO.id,
                            title: cardDTO.title,
                            topKeyword: cardDTO.topKeyword,
                            summary: cardDTO.summary,
                            contentURL: cardDTO.contentURL,
                            newsletterName: cardDTO.newsletterName,
                            language: cardDTO.language
                        )
                    }
                    return cards
                },
                fetchExploreCards: { requestDTO in
                    let response = try await apiClient.request(CardAPI.fetchExploreCard(requestDTO))
                        .map(ExploreCardResponseDTO.self)
                    return response.toDomain()
                },
                refreshCards: { userId in
                    _ = try await apiClient.request(CardAPI.refreshCards(userId: userId))
                },
                fetchOGShareURL: { requestDTO in
                    let textColorEncoded = requestDTO.textColor?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let urlString = "https://fairy-band.com/api/share/og?exposureContentId=\(requestDTO.exposureContentId)&textColor=\(textColorEncoded)"
                    return urlString
                }
            )
        }()

    static var previewValue: CardClient = {
        return CardClient(
            fetchCards: { _,_  in
                return [
                    Card(id: 1192, title: "Preview Title 1", topKeyword: "Preview Keyword 1", summary: "Preview Summary 1", contentURL: "https://example.com", newsletterName: "Preview Newsletter 1", language: "ENGLISH"),
                    Card(id: 1201, title: "Preview Title 2", topKeyword: "Preview Keyword 2", summary: "Preview Summary 2", contentURL: "https://example.com", newsletterName: "Preview Newsletter 2", language: "ENGLISH"),
                    Card(id: 1170, title: "Preview Title 3", topKeyword: "Preview Keyword 3", summary: "Preview Summary 3", contentURL: "https://example.com", newsletterName: "Preview Newsletter 3", language: "ENGLISH"),
                    Card(id: 1123, title: "Preview Title 4", topKeyword: "Preview Keyword 4", summary: "Preview Summary 4", contentURL: "https://example.com", newsletterName: "Preview Newsletter 4", language: "ENGLISH"),
                    Card(id: 1148, title: "Preview Title 5", topKeyword: "Preview Keyword 5", summary: "Preview Summary 5", contentURL: "https://example.com", newsletterName: "Preview Newsletter 5", language: "ENGLISH"),
                    Card(id: 938, title: "Preview Title 6", topKeyword: "Preview Keyword 6", summary: "Preview Summary 6", contentURL: "https://example.com", newsletterName: "Preview Newsletter 6", language: "ENGLISH")
                ]
            },
            fetchExploreCards: { _ in
                return .stub()
            },
            refreshCards: { _ in },
            fetchOGShareURL: { _ in
                return "https://fairy-band.com/api/share/og?exposureContentId=2&textColor=%23DCFF64"
            }
        )
    }()

    static var testValue: CardClient = previewValue
}

