//
//  NewsletterReportAPI.swift
//  NewsLetter
//

import Foundation

import Moya

enum NewsletterReportAPI {
    case submitReport(NewsletterReportRequestDTO)
}

extension NewsletterReportAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)")!
    }

    var path: String {
        return "/api/newsletters/content-provider-requests"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .submitReport(let dto):
            guard let parameters = try? JSONEncoder().encode(dto),
                  let dict = try? JSONSerialization.jsonObject(with: parameters) as? [String: Any] else {
                return .requestPlain
            }
            return .requestParameters(parameters: dict, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
