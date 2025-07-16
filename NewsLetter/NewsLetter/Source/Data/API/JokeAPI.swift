//
//  JokeAPI.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/16/25.
//

import Foundation

import Moya

enum JokeAPI {
    case fetchAnyJokes
}

extension JokeAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://sv443.net/jokeapi/v2")!
    }
    
    var path: String {
        switch self {
        case .fetchAnyJokes: return "/joke/Any"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAnyJokes: return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchAnyJokes: return .requestPlain
        }
    }
}
