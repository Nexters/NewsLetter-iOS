//
//  Dictionary+.swift
//  NewsLetter
//
//  Created by 이조은 on 9/30/25.
//

import Foundation

public extension Dictionary where Key == String, Value == Any {
    func toJSONString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
}
