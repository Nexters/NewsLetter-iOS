//
//  OGShareURLRequestDTO.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/21/25.
//

import Foundation

struct OGShareURLRequestDTO: Encodable {
    let exposureContentId: Int64
    let backgroundColor: String?
    let textColor: String?
}
