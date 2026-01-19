//
//  UpdateInfoDTO.swift
//  NewsLetter
//
//  Created by 이조은 on 1/16/26.
//

struct UpdateInfoDTO: Decodable {
    let min_version: String
    let latest_version: String
    let store_url: String
    let message: String?
}
