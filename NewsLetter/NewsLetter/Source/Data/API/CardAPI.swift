//
//  CardAPI.swift
//  NewsLetter
//
//  Created by 이조은 on 8/1/25.
//

import Foundation

import Moya

enum CardAPI {
    case fetchCards(userId: String, publishedDate: String?)
    case fetchOGShareURL(OGShareURLRequestDTO)
}

extension CardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://\(AppInfo.baseURL)/api")!
    }

    var path: String {
        switch self {
        case .fetchCards(let userId, let publishedDate):
            var urlPath = "/api/newsletters/contents/\(userId)"
            if let date = publishedDate {
                urlPath += "?publishedDate=\(date)"
            }
            return urlPath
        case .fetchOGShareURL:
            return "/share/og"
        }
    }

    var method: Moya.Method {
        switch self {
        default: return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchCards:
            return .requestPlain
        case .fetchOGShareURL(let dto):
            guard let parameters = dto.toDictionary() else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
