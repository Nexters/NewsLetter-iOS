//
//  ExploreCard.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/27/25.
//

struct ExploreCard: Codable {
    let id: Int
    let title: String
    let topKeyword: String
    let summary: String
    let newsletterName: String
    let contentURL: String

    static func stub(
        id: Int = 1,
        title: String = "AI, 테스트 리팩토링을 지배하다!",
        topKeyword: String = "Kotlin",
        summary: String = "summary",
        newsletterName: String = "안드로이드 위클리",
        contentURL: String = "https://www.youtube.com/watch?v=RNfwJLjkd3c"
    ) -> Self {
        .init(
            id: id,
            title: title,
            topKeyword: topKeyword,
            summary: summary,
            newsletterName: newsletterName,
            contentURL: contentURL,
        )
    }
    
    func toCard() -> Card {
        .init(
            id: id,
            title: title,
            topKeyword: topKeyword,
            summary: summary,
            contentURL: contentURL,
            newsletterName: newsletterName,
            language: "stub" // FIXME: 현재 API Response에서 언어 정보가 넘어오지 않아서 표현 못해줌 백엔드와 의논필요
        )
    }
}
