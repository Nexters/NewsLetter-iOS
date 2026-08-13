//
//  MarkdownAPI.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import Foundation

import Moya

enum MarkdownAPI {
    case fetchMarkdown(exposureContentId: Int)
}

extension MarkdownAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)")!
    }

    var path: String {
        switch self {
        case .fetchMarkdown(let exposureContentId):
            return "/api/newsletters/exposure-contents/\(exposureContentId)/markdown"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
