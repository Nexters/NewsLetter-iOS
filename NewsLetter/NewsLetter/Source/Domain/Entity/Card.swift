//
//  Card.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/21/25.
//

struct Card: Codable {
    let id: Int
    let title: String
    let topKeyword: String
    let summary: String
    let contentURL: String
    let imageURL: String?
    let newsletterName: String
    let language: String
    let cardType: CardType

    var displayLanguage: String {
        switch language.uppercased() {
        case "ENGLISH": return "영어"
        case "KOREAN": return "한국어"
        default:        return "기타"
        }
    }

    // Card를 스텁 데이터로 초기화하는 함수
    static func stub(
        id: Int = 1192, 
        title: String = "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔",
        topKeyword: String = "Kotlin",
        summary: String = "Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역직렬화할 때 실제 싱글톤 동작을 유지하려면 사용자 정의 어댑터가 필요하다고 강조합니다.Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역렬화할 때 실제 싱글톤 동작을 강조합니다.",
        contentURL: String = "https://substack.com/redirect/3966a1cb-5964-4e4c-a46c-67fd93586b71?j=eyJ1IjoiNjBoYXcyIn0.sgwjhuRgLj2i1p7EiKYAd1HGVttvTH1zz-7ivhBT090",
        imageURL: String = "https://picsum.photos/400/300",
        newsletterName: String = "안드로이드 위클리",
        language: String = "ENGLISH",
        cardType: CardType = .newsletter
    ) -> Self {
        return .init(
            id: id,
            title: title,
            topKeyword: topKeyword,
            summary: summary,
            contentURL: contentURL,
            imageURL: imageURL,
            newsletterName: newsletterName,
            language: language,
            cardType: cardType
        )
    }
}
