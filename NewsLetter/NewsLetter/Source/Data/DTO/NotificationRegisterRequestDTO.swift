//
//  NotificationRegisterRequestDTO.swift
//  NewsLetter
//
//  Created by 이조은 on 8/7/25.
//

struct RegisterNotificationRequestDTO: Encodable {
    let deviceToken: String
    let fcmToken: String
    let deviceType: String
}
