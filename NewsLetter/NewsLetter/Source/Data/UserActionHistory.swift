//
//  UserActionHistory.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/30/25.
//

import Foundation

struct UserActionHistory {
    /// 유저가 처음 앱을 실행했는지 여부
    @UserDefaultWrapper(key: "isFirstAppLaunch", defaultValue: true)
    static var isFirstAppLaunch: Bool
    
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
    
    /// 유저가 정보 등록을 거부한 날짜
    @UserDefaultWrapper(key: "deniedDateWhenInputJobDetail", defaultValue: nil)
    static var deniedDateWhenInputJobDetail: Date?
    
    /// 유저가 알림 받기를 거부한 날짜
    @UserDefaultWrapper(key: "deniedDateWhenSetNotification", defaultValue: nil)
    static var deniedDateWhenSetNotification: Date?
    
    /// 유저가 마지막 방문한 날짜
    @UserDefaultWrapper(key: "lastVisitDate", defaultValue: nil)
    static var lastVisitDate: Date?
    
    /// 유저의 연속 방문 일수
    @UserDefaultWrapper(key: "streakCount", defaultValue: 1)
    static var streakCount: Int
}
