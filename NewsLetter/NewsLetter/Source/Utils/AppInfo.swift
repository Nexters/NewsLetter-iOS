//
//  AppInfo.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/13/25.
//

import Foundation

struct AppInfo {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    static var baseURL: String {
        Bundle.main.infoDictionary?["BASE_URL"] as? String ?? "fairy-band.com"
    }
    
    static func value(forKey key: String) -> String? {
        Bundle.main.infoDictionary?[key] as? String
    }
}
