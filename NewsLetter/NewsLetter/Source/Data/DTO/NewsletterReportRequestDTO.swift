//
//  NewsletterReportRequestDTO.swift
//  NewsLetter
//

import Foundation

struct NewsletterReportRequestDTO: Encodable {
    let contentProviderName: String
    let channel: String
    let requestCategory: String
    let relatedTo: String
    let reason: String
}
