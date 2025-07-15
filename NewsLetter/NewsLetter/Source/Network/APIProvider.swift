//
//  APIProvider.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/13/25.
//

import Moya

struct APIProvider {
    static let shared = MoyaProvider<MultiTarget>(
        session: Session(interceptor: CommonHeaderInterceptor()),
        plugins: [NetworkLoggerPlugin()]
    )
}
  
