//
//  CardAPI.swift
//  NewsLetter
//
//  Created by 이조은 on 8/1/25.
//

import Foundation

import Moya

let BASE_URL = Bundle.main.infoDictionary?["BASE_URL"] as? String ?? "fairy-band.com"

enum CardAPI {
    case fetchCards(userId: String, publishedDate: String?)
}

extension CardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://\(BASE_URL)/api/api")!
    }

    var path: String {
        switch self {
        case .fetchCards(let userId, let publishedDate):
            var urlPath = "/newsletters/contents/\(userId)"
            if let date = publishedDate {
                urlPath += "?publishedDate=\(date)"
            }
            return urlPath
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchCards: return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchCards:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
