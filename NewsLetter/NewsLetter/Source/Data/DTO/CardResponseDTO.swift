//
//  CardDTO.swift
//  NewsLetter
//
//  Created by 이조은 on 8/1/25.
//

import Foundation

// MARK: - CardClient
struct CardResponseDTO: Decodable {
    let publishedDate: String
    let cards: [CardDTO]
}

// MARK: - Card
struct CardDTO: Decodable {
    let id: Int
    let title, topKeyword, summary: String
    let contentURL: String
    let newsletterName: String

    enum CodingKeys: String, CodingKey {
        case id
        case title, topKeyword, summary
        case contentURL = "contentUrl"
        case newsletterName
    }
}

/*
 MARK: 응답 케이스 예시

 {
     "publishedDate": "2025-08-01",
     "cards": [
         {
             "title": "웹 개발, 혁신인가, 자충수인가?",
             "topKeyword": "개발방법론",
             "summary": "현대 웹 개발은 지나치게 복잡해져 사용자 경험을 해치고 있다는 비판적인 내용입니다. 개발자 중심의 사고방식과 과도한 기술 사용이 웹의 속도 저하, 유지 보수 어려움, 접근성 문제 등을 야기하며, 웹의 본질을 잃어가고 있다고 지적합니다.",
             "contentUrl": "https://substack.com/redirect/3966a1cb-5964-4e4c-a46c-67fd93586b71?j=eyJ1IjoiNjBoYXcyIn0.sgwjhuRgLj2i1p7EiKYAd1HGVttvTH1zz-7ivhBT090",
             "newsletterName": "Korean FE Article"
         },
         {
             "title": "사이드 프로젝트, AI로 출시까지? 지금 바로 시작!",
             "topKeyword": "개발 기기",
             "summary": "AI 코딩 에이전트를 활용하여 1,000줄 미만의 코드로 2만 줄 이상의 macOS 앱을 개발하고 출시한 경험을 공유합니다. 프롬프트 중심 개발, 자동화, 테스트, 문서화, 배포 등 AI를 활용하여 코드 품질과 생산성을 높이고, 반복 작업을 줄였습니다. 앞으로의 IDE 변화와 AI를 통한 사이드 프로젝트 성공 사례를 제시합니다.",
             "contentUrl": "https://news.hada.io/topic?id=21847&utm_source=weekly&utm_medium=email&utm_campaign=202528",
             "newsletterName": "GeekNews"
         },
         {
             "title": "React Native, 성능 한계 돌파?",
             "topKeyword": "No Keywords",
             "summary": "Callstack 팀이 React Native에 Node-API 지원을 발표했습니다. 이는 React Native의 성능 향상과 기능 확장에 기여할 것으로 예상됩니다. 개발자들은 이 소식에 큰 기대를 걸고 있습니다.",
             "contentUrl": "https://bytes.dev/archives/408?ck_subscriber_id=3475865219",
             "newsletterName": "Bytes"
         },
         {
             "title": "NGINX 기반 WAF, 보안의 판도를 뒤집다",
             "topKeyword": "개발문화",
             "summary": "BunkerWeb은 NGINX 기반 리버스 프록시와 차세대 WAF를 결합하여 클라우드 네이티브 환경에서 강력한 보안을 제공하는 프로젝트입니다. Linux, Docker, Kubernetes 등 다양한 환경과의 연동, 직관적인 UI, 자동화된 설정, 확장 가능한 플러그인 시스템을 통해 개발자와 기업의 보안 문제를 해결합니다.",
             "contentUrl": "https://news.hada.io/topic?id=21871&utm_source=weekly&utm_medium=email&utm_campaign=202528",
             "newsletterName": "GeekNews"
         },
         {
             "title": "이 기술, 당신의 웹 앱을 혁신한다!",
             "topKeyword": "React.js",
             "summary": "이 데이터그리드는 최신 웹 앱 구축을 위한 빠르고 유연한 솔루션입니다. 핵심 기능과 가상화된 렌더링을 제공하며, Angular, React, Vue 등 다양한 프레임워크와 호환됩니다. 앱 크기를 최소화하는 특수 기능을 통해 효율적인 개발을 지원합니다.",
             "contentUrl": "https://developer.mescius.com/wijmo/flexgrid-javascript-data-grid?utm_source=CooperPress&utm_medium=JavaScript-Weekly&utm_campaign=Wijmo-JS-Weekly-Primary-Sponsor-July-2025",
             "newsletterName": "JavaScript Weekly"
         },
         {
             "title": "REST API, 당신이 잘못 알고 있는 진실",
             "topKeyword": "경험",
             "summary": "대부분의 RESTful API가 REST 원칙을 제대로 따르지 않고, 실용적인 이유로 RPC 스타일에 가까워지는 경향이 있습니다. 진정한 REST는 하이퍼미디어를 통해 서버-클라이언트 결합도를 낮추는 것이 핵심이며, API 설계 시에는 실용성과 오용 방지에 초점을 맞춰야 합니다.",
             "contentUrl": "https://news.hada.io/topic?id=21907&utm_source=weekly&utm_medium=email&utm_campaign=202528",
             "newsletterName": "GeekNews"
         }
     ]
 }

*/
