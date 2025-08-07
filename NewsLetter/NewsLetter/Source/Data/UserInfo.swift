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

    /// 유저의 카드 정보(하루에 1번 갱신)
    @UserDefaultWrapper(key: "cachedDailyCards", defaultValue: nil)
    static var cachedDailyCards: [Card]?

    /// 매핑된 카드 컬러 정보
    @UserDefaultWrapper(key: "cachedDailyColors", defaultValue: nil)
    static var cachedDailyColors: [ColorPaletteName]?

    /// 유저가 마지막 API를 호출한 날짜
    @UserDefaultWrapper(key: "lastCardFetchDate", defaultValue: nil)
    static var lastCardFetchDate: Date?
}
