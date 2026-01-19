//
//  ExploreCardResponse.swift
//  NewsLetter
//
//  Created by 이원빈 on 1/11/26.
//

import Foundation

struct ExploreCardResponse: Codable {
    let contents: [ExploreCard]
    let totalCount: Int
    let hasMore: Bool
    let nextOffset: Int
    
    static func stub(
        contents: [ExploreCard] = [
            .stub(id: 1), .stub(id: 2), .stub(id: 3),
            .stub(id: 4), .stub(id: 5), .stub(id: 6),
            .stub(id: 7), .stub(id: 8), .stub(id: 9)
        ],
        hasMore: Bool = false,
        nextOffset: Int = 0,
        totalCount: Int = 0
    ) -> Self {
        .init(
            contents: contents,
            totalCount: totalCount,
            hasMore: hasMore,
            nextOffset: nextOffset
        )
    }
}
