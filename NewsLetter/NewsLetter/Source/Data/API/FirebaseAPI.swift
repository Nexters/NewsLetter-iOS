//
//  FirebaseAPI.swift
//  NewsLetter
//
//  Created by 이조은 on 8/7/25.
//

import Foundation

import Moya

enum FirebaseAPI {
    case registerNotification(dto: RegisterNotificationRequestDTO)
}

extension FirebaseAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)/api")!
    }

    var path: String {
        switch self {
        case .registerNotification:
            return "/notifications/token"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registerNotification:
            return .post
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var task: Task {
        switch self {
        case .registerNotification(let dto):
            return .requestJSONEncodable(dto)
        }
    }
}
