//
//  UserUpdateRequestDTO.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

// API 요청 DTO 모델
struct UserUpdateRequestDTO: Codable {
    let preferences: [Preference]
    let workingExperience: WorkingExperience
}

// 직군 정보 (preference)를 나타내는 열거형
// 서버와 통신하는 API 명세에 따라 CaseIterable 프로토콜을 추가하면 유용할 수 있습니다.
enum Preference: String, Codable, CaseIterable {
    case android = "ANDROID"
    case iOS = "IOS"
    case frontend = "FRONTEND"
    case backend = "BACKEND"
    case devops = "DEVOPS"
}

// 연차 정보 (workingExperience)를 나타내는 열거형
enum WorkingExperience: String, Codable, CaseIterable {
    case student = "STUDENT"
    case junior = "JUNIOR"
    case mid = "MID"
    case senior = "SENIOR"
    case expert = "EXPERT"
}
