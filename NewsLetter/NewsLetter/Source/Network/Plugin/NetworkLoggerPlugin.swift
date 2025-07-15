//
//  NetworkLoggerPlugin.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/13/25.
//

import Moya

final class NetworkLoggerPlugin: PluginType {
    func willSend(_ request: any RequestType, target: any TargetType) {
        guard let request = request.request else {
            print("요청을 생성할 수 없습니다: \(target.path)")
            return
        }
        
        let method = request.httpMethod ?? "N/A"
        let url = request.url?.absoluteString ?? "N/A"
        let headers = request.allHTTPHeaderFields ?? [:]
        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "없음"
        
        print("""
               ✅ [Moya 요청 시작]
               ┌─────── Request ───────
               │ URL     : \(url)
               │ Method  : \(method)
               │ Headers : \(headers)
               │ Body    : \(body)
               └──────────────────────
               """)
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        switch result {
        case .success(let response):
            let statusCode = response.statusCode
            let url = response.request?.url?.absoluteString ?? "N/A"
            let responseData = String(data: response.data, encoding: .utf8) ?? "없음"
            print("""
                       🎯 [Moya 응답 수신]
                       ┌─────── Response ───────
                       │ URL      : \(url)
                       │ Status   : \(statusCode)
                       │ Body     : \(responseData)
                       └────────────────────────
                       """)
        case .failure(let error):
            print("""
                        ❌ [Moya 에러]
                        ┌─────── Error ───────
                        │ Description : \(error.localizedDescription)
                        │ FailureType : \(type(of: error))
                        │ Response    : \(String(describing: error.response))
                        └────────────────────
                        """)
        }
    }
}
