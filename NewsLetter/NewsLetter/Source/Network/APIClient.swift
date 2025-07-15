//
//  APIClient.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/13/25.
//

import Foundation
import Combine

import CombineMoya
import Moya

protocol APIClient {
    func request<T: Decodable>(_ target: TargetType, as type: T.Type) -> AnyPublisher<T, APIError>
}

final class MoyaAPIClient: APIClient {
    private let provider: MoyaProvider<MultiTarget>
    
    init(provider: MoyaProvider<MultiTarget> = APIProvider.shared) {
        self.provider = provider
    }
    
    func request<T: Decodable>(_ target: TargetType, as type: T.Type) -> AnyPublisher<T, APIError> {
        provider.requestPublisher(MultiTarget(target))
            .tryMap { response in
                if  200..<300 ~= response.statusCode {
                    return response.data
                } else {
                    throw APIError.serverError(code: response.statusCode)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is DecodingError:            return .decodingError
                case let moyaError as MoyaError:  return self.handleMoyaError(moyaError)
                case let apiError as APIError:    return apiError
                default:                          return .unknown
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func handleMoyaError(_ moyaError: MoyaError) -> APIError {
        if case let .statusCode(response) = moyaError {
            return .serverError(code: response.statusCode)
        }
        return .unknown
    }
}
