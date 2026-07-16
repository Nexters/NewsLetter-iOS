//
//  UserAPI.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

import Moya

enum UserAPI {
    case login(UserLoginRequestDTO)
    case register(UserRegisterRequestDTO)
    case update(userId: Int, requestDTO: UserUpdateRequestDTO)
    case fetchUser(userId: Int)
}

extension UserAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)/api")!
    }
    
    var path: String {
        switch self {
        case .login:                  return "/users/login"
        case .register:               return "/users/register"
        case .update(let userId, _):  return "/users/\(userId)"
        case .fetchUser(let userId):  return "/users/\(userId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:      return .get
        case .register:   return .post
        case .update:     return .put
        case .fetchUser:  return .get
        }
    }

    var task: Task {
        switch self {
        case .login(let dto):
            guard let parameters = dto.toDictionary() else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case .register(let dto):
            guard let parameters = dto.toDictionary() else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        case .update(_, let dto):
            guard let parameters = dto.toDictionary() else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        case .fetchUser:
            return .requestPlain
        }
    }
}
