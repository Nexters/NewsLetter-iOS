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
    case refreshCards(userId: String)
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
        case .refreshCards(let userId):
            return "/api/newsletters/contents/\(userId)/refresh"
        case .fetchOGShareURL:
            return "/share/og"
        }
    }

    var method: Moya.Method {
        switch self {
        case .refreshCards: return .post
        default:            return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchCards, .refreshCards:
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
        var h: [String: String] = ["Content-Type": "application/json"]
        h["Accept-Language"] = languageTagForHeader()
        return h
    }

    private func languageTagForHeader() -> String {
        let lang = Locale.preferredLanguages.first ?? "en-US"
        switch lang {
        case "en-US": return "en-US"
        case "ko-KR": return "ko-KR"
        default:   return "en-US"
        }
    }
}
