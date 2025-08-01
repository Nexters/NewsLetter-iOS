//
//  UserAPI.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

import Moya

enum UserAPI {
    case register(UserRegisterRequestDTO)
    case update(userId: Int, requestDTO: UserUpdateRequestDTO)
}

extension UserAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "http://\(BASE_URL)/api/api")!
    }
    
    var path: String {
        switch self {
        case .register: return "/users/register"
        case .update(let userId, _): return "/users/\(userId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register: return .post
        case .update: return .put
        }
    }
    
    var task: Task {
        switch self {
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
        }
    }
}
