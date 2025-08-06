//
//  Card.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/21/25.
//

struct Card: Codable {
    let title: String
    let topKeyword: String
    let summary: String
    let contentURL: String
    let newsletterName: String

    // Card를 스텁 데이터로 초기화하는 함수
    static func stub(
        title: String = "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔",
        topKeyword: String = "Kotlin | 안드로이드 위클리",
        summary: String = "Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역직렬화할 때 실제 싱글톤 동작을 유지하려면 사용자 정의 어댑터가 필요하다고 강조합니다.Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역렬화할 때 실제 싱글톤 동작을 강조합니다.",
        contentURL: String = "https://substack.com/redirect/3966a1cb-5964-4e4c-a46c-67fd93586b71?j=eyJ1IjoiNjBoYXcyIn0.sgwjhuRgLj2i1p7EiKYAd1HGVttvTH1zz-7ivhBT090",
        newsletterName: String = "Kotlin Article"
    ) -> Self {
        return .init(
            title: title,
            topKeyword: topKeyword,
            summary: summary,
            contentURL: contentURL,
            newsletterName: newsletterName
        )
    }
}
