//
//  DateCalculator.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

struct DateCalculator {
    // 앱 실행 시 호출하여 연속 방문을 확인하고 업데이트하는 함수
    static func checkAndIncrementVisitStreak() {
        let today = Date()
        let calendar = Calendar.current
        
        if let lastDate = UserActionHistory.lastVisitDate {
            let components = calendar.dateComponents([.day], from: lastDate, to: today)
            let dayDifference = components.day ?? 0
            
            if dayDifference == 1 {
                UserActionHistory.streakCount += 1
            } else if dayDifference > 1 {
                UserActionHistory.streakCount = 1
            }
        } else {
            UserActionHistory.streakCount = 1
        }
        
        UserActionHistory.lastVisitDate = today
    }
    
    static func isCanShowNotificationPermissionBottomSheet() -> Bool {
        guard let eventDate = UserActionHistory.deniedDateWhenSetNotification else {
            return true
        }

        return calculatePassDays(from: eventDate) >= 3
    }
    
    static func isCanShowJobDetailBottomSheet() -> Bool {
        guard let eventDate = UserActionHistory.deniedDateWhenInputJobDetail else {
            return true
        }

        return calculatePassDays(from: eventDate) >= 7
    }
    
    static func calculatePassDays(from date: Date) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: today)
        return components.day ?? 0
    }

    static func todayFormattedString(format: String = "yyyy.MM.dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date())
    }

    static func secondsUntilMidnight(from date: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let midnight = calendar.nextDate(
            after: date,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return 0
        }
        return Int(midnight.timeIntervalSince(date))
    }

    static func todayWithoutTime() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
}
