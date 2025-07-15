//
//  CommonHeaderInterceptor.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/14/25.
//

import Foundation

import Alamofire

class CommonHeaderInterceptor: Interceptor {
    override func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        completion(.success(request))
    }
}
