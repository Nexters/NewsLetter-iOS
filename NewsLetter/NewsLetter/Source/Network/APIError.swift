//
//  APIError.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/13/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case decodingError
    case serverError(code: Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .decodingError:         return "데이터를 디코딩하는 데 실패했습니다."
        case .serverError(let code): return "서버 오류가 발생했습니다. 오류 코드: \(code)"
        case .unknown:               return "알 수 없는 오류가 발생했습니다."
        }
    }
}
