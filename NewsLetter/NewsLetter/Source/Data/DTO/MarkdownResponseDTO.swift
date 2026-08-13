//
//  MarkdownResponseDTO.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import Foundation

struct MarkdownResponseDTO: Decodable {
    let exposureContentId: Int
    let markdownContent: String
}
