//
//  FetchCardsRequestDTO.swift
//  NewsLetter
//

import Foundation

struct FetchCardsRequestDTO: Encodable {
    let userId: String
    let publishedDate: String?
}
