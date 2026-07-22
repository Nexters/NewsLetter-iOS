//
//  ExploreCardRequestDTO.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/24/25.
//

import Foundation

struct ExploreCardRequestDTO: Encodable {
    let lastSeenOffset: Int64
    let size: Int32
    let sort: String
    let direction: String
    let categoryIds: [String]?
}
