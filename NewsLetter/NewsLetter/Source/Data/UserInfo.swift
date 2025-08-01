//
//  UserInfo.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

struct UserInfo {
    /// 유저의 유니크 id
    @UserDefaultWrapper(key: "userId", defaultValue: nil)
    static var userId: Int?
}
