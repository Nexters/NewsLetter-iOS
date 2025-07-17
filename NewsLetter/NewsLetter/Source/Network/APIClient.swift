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
    func request(_ target: TargetType) -> AnyPublisher<Response, MoyaError>
    func request(_ target: TargetType) async throws -> Response
}

final class MoyaAPIClient: APIClient {
    private let provider: MoyaProvider<MultiTarget>
    
    init(provider: MoyaProvider<MultiTarget> = APIProvider.shared) {
        self.provider = provider
    }
    
    func request(_ target: TargetType) -> AnyPublisher<Response, MoyaError> {
        provider.requestPublisher(MultiTarget(target))
    }
    
    func request(_ target: TargetType) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.target(target)) { result in
                switch result {
                case let .success(response) where 200..<300 ~= response.statusCode:
                    continuation.resume(returning: response)
                case let .success(response) where 300... ~= response.statusCode:
                    continuation.resume(throwing: MoyaError.statusCode(response))
                case let .failure(error):
                    continuation.resume(throwing: error)
                default:
                    let unknownError = NSError(
                        domain: "com.nexters.newsletter",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."]
                    )
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
}
