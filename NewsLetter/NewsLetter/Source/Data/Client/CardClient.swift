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

    var fetchCards: (String, String?) async throws -> [Card]
    var refreshCards: (String) async throws -> Void
    var fetchOGShareURL: (OGShareURLRequestDTO) async throws -> OGShareURLResponseDTO
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
                            title: cardDTO.title,
                            topKeyword: cardDTO.topKeyword,
                            summary: cardDTO.summary,
                            contentURL: cardDTO.contentURL,
                            newsletterName: cardDTO.newsletterName
                        )
                    }
                    return cards
                },
                refreshCards: { userId in
                    _ = try await apiClient.request(CardAPI.refreshCards(userId: userId))
                },
                fetchOGShareURL: { requestDTO in
                    let response = try await apiClient.request(CardAPI.fetchOGShareURL(requestDTO))
                    let ogShareURL = try response.map(OGShareURLResponseDTO.self)
                    return ogShareURL
                }
            )
        }()

    static var previewValue: CardClient = {
        return CardClient(
            fetchCards: { _,_  in
                return [
                    Card(title: "Preview Title 1", topKeyword: "Preview Keyword 1", summary: "Preview Summary 1", contentURL: "https://example.com", newsletterName: "Preview Newsletter 1"),
                    Card(title: "Preview Title 2", topKeyword: "Preview Keyword 2", summary: "Preview Summary 2", contentURL: "https://example.com", newsletterName: "Preview Newsletter 2"),
                    Card(title: "Preview Title 3", topKeyword: "Preview Keyword 3", summary: "Preview Summary 3", contentURL: "https://example.com", newsletterName: "Preview Newsletter 3"),
                    Card(title: "Preview Title 4", topKeyword: "Preview Keyword 4", summary: "Preview Summary 4", contentURL: "https://example.com", newsletterName: "Preview Newsletter 4"),
                    Card(title: "Preview Title 5", topKeyword: "Preview Keyword 5", summary: "Preview Summary 5", contentURL: "https://example.com", newsletterName: "Preview Newsletter 5"),
                    Card(title: "Preview Title 6", topKeyword: "Preview Keyword 6", summary: "Preview Summary 6", contentURL: "https://example.com", newsletterName: "Preview Newsletter 6")
                ]
            },
            refreshCards: { _ in },
            fetchOGShareURL: { _ in
                return "www.example-og-share-url.com"
            }
        )
    }()

    static var testValue: CardClient = previewValue
}

