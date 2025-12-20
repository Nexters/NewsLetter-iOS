//
//  ExploreCardResponseDTO.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/24/25.
//

import Foundation

struct ExploreCardResponseDTO: Decodable {
    let contents: [ExploreCardDTO]
    let hasMore: Bool
    let nextOffset: Int
}
struct ExploreCardDTO: Decodable {
    let id: Int
    let contentId: Int
    let provocativeKeyword: String
    let provocativeHeadline: String
    let summaryContent: String
    let contentURL: String
    let newsletterName: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, contentId
        case provocativeKeyword, provocativeHeadline, summaryContent
        case contentURL = "contentUrl"
        case newsletterName
        case createdAt, updatedAt
    }
}
/*
 // MARK: 응답예시
 {
   "contents": [
     {
       "id": 2,
       "contentId": 1,
       "provocativeKeyword": "경험",
       "provocativeHeadline": "상처 주는 조언, 이제 그만! 인정의 기술",
       "summaryContent": "상대방을 이해하고 인정하는 공감 능력이 부족해 관계가 어려워지는 현 시대에, 『인정의 기술』의 8단계를 통해 관계를 회복하는 방법을 제시합니다. 경청, 공감, 행동의 단계를 거쳐 진정한 소통을 이루고, AI 시대에 인간 관계의 중요성을 강조합니다.",
       "contentUrl": "https://stibee.com/api/v1.0/emails/share/xEmgO6sOv_t1j-Uy-fypX-LuD2nIdN0",
       "newsletterName": "당근메일",
       "createdAt": "2025-07-29T10:34:54.812641",
       "updatedAt": "2025-07-29T10:34:54.812669"
     },
     {
       "id": 3,
       "contentId": 11,
       "provocativeKeyword": "AI",
       "provocativeHeadline": "AI, 테스트 리팩토링을 지배하다!",
       "summaryContent": "Duncan McGregor는 AI를 활용한 테스트 리팩토링 자동화를 탐구하며, '보고 따라 하기, 해보고 가르치기' 방식을 적용했습니다. 실험 결과는 엇갈렸지만, 프롬프트 디자인에 대한 귀중한 통찰력을 얻었습니다. AI를 활용한 테스트 자동화의 가능성과 한계를 보여주는 연구입니다.",
       "contentUrl": "https://www.youtube.com/watch?v=RNfwJLjkd3c",
       "newsletterName": "Kotlin Weekly",
       "createdAt": "2025-07-29T13:12:11.987685",
       "updatedAt": "2025-07-29T13:12:11.987698"
     }
   ],
   "hasMore": true,
   "nextOffset": 3
 }
 */
