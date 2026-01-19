//
//  FirebaseConfig.swift
//  NewsLetter
//
//  Created by 이조은 on 1/16/26.
//

import Foundation

struct FirebaseConfig: Equatable {
    // A/B 테스팅 관련 플래그
    let colorFlag: String
    let mainDescFlag: String

    // 업데이트 관련 정보
    let minVersion: String
    let latestVersion: String
    let storeURL: String
    let updateMessage: String
}
