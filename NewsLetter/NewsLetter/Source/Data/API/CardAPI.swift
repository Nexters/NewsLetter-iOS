//
//  CardAPI.swift
//  NewsLetter
//
//  Created by 이조은 on 8/1/25.
//

import Foundation

import Moya

enum CardAPI {
    case fetchCards(FetchCardsRequestDTO)
    case fetchExploreCard(ExploreCardRequestDTO)
    case refreshCards(RefreshCardsRequestDTO)
    case fetchOGShareURL(OGShareURLRequestDTO)
}

extension CardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)")!
    }

    var path: String {
        switch self {
        case .fetchCards(let dto):
            var urlPath = "/api/newsletters/contents/\(dto.userId)"
            if let date = dto.publishedDate {
                urlPath += "?publishedDate=\(date)"
            }
            return urlPath
        case .fetchExploreCard:
            return "api/newsletters/explore/contents"
        case .refreshCards(let dto):
            return "/api/newsletters/contents/\(dto.userId)/refresh"
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
        case .fetchExploreCard(let dto):
            guard let parameters = dto.toDictionary() else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding(destination: .queryString, arrayEncoding: .noBrackets)
            )
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
