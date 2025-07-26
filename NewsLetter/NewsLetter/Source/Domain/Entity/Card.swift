//
//  Card.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/21/25.
//

struct Card {
    let title: String
    let keyword: String
    let description: String
    
    static func stub(
        title: String = "일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔",
        keyword: String = "Kotlin | 안드로이드 위클리",
        description: String = "Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역직렬화할 때 실제 싱글톤 동작을 유지하려면 사용자 정의 어댑터가 필요하다고 강조합니다.Anatolii Frolov는 Kotlin 객체 싱글톤이 Gson과 같은 라이브러리에 의해 복제될 수 있으므로 역렬화할 때 실제 싱글톤 동작을 강조합니다."
    ) -> Self {
        .init(
            title: title,
            keyword: keyword,
            description: description
        )
    }
}
