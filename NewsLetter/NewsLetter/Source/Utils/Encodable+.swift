//
//  Encodable+.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

extension Encodable {
  func toDictionary() -> [String: Any]? {
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(self) else {
      return nil
    }
    guard let dictionary = try? JSONSerialization.jsonObject(
      with: data,
      options: .allowFragments
    ) as? [String: Any] else {
      return nil
    }
    return dictionary
  }
}

