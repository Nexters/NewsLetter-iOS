//
//  UserActionHistory.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/30/25.
//

import Foundation

struct UserActionHistory {
    /// 유저가 첫 카드를 열고 닫았는지 여부
    @UserDefaultWrapper(key: "isFirstLook", defaultValue: false)
    static var isFirstLook: Bool
    
    /// 유저가 정보 등록을 완료했는지 여부
    @UserDefaultWrapper(key: "isAlreadyInputJobDetail", defaultValue: false)
    static var isAlreadyInputJobDetail: Bool

    /// 유저의 직군
    @UserDefaultWrapper(key: "selectedCareer", defaultValue: [])
    static var selectedCareer: [[String]]

    /// 유저의 직군이 변경되었는지 확인
    @UserDefaultWrapper(key: "isChangedCareer", defaultValue: false)
    static var isChangedCareer: Bool

    /// 유저가 알림 받기를 완료했는지 여부
    @UserDefaultWrapper(key: "isAlreadySetNotification", defaultValue: false)
    static var isAlreadySetNotification: Bool
    
    /// 유저가 알림 받기를 거부한 날짜
    @UserDefaultWrapper(key: "deniedDateWhenSetNotification", defaultValue: nil)
    static var deniedDateWhenSetNotification: Date?
    
    /// 유저가 마지막 방문한 날짜
    @UserDefaultWrapper(key: "lastVisitDate", defaultValue: nil)
    static var lastVisitDate: Date?
    
    /// 유저의 연속 방문 일수
    @UserDefaultWrapper(key: "streakCount", defaultValue: 1)
    static var streakCount: Int
    
    /// 유저의 새로고침 사용 날짜
    @UserDefaultWrapper(key: "useRefreshDate", defaultValue: nil)
    static var useRefreshDate: Date?

    /// 온보딩 둘째날 직군 변경 바텀시트 플로우가 종료되었는지 여부. true가 되면 서버에 온보딩 상태를 다시 확인하지 않습니다.
    @UserDefaultWrapper(key: "isOnboardingFlowFinished", defaultValue: false)
    static var isOnboardingFlowFinished: Bool
}
