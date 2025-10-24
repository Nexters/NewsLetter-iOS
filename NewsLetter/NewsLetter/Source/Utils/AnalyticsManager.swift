//
//  AnalyticsManager.swift
//  NewsLetter
//
//  Created by 이조은 on 9/28/25.
//

import Foundation

import FirebaseAnalytics

enum GA {

    // MARK: - Newsletter Main

    static func pageview_main() {
        Analytics.logEvent("pageview_main", parameters: [
            "category": "pageview",
            "navigation": "main"
        ])
    }

    static func click_newsletter(title: String, listIndex: Int) {
        let dataString = ["list_index": listIndex].toJSONString()
        Analytics.logEvent("click_newsletter", parameters: [
            "category": "click",
            "navigation": "main",
            "object_section": "newsletter_list",
            "object_type": "newsletter",
            "object_id": title,
            "data": dataString ?? ""
        ])
    }

    // MARK: - Newsletter Carousel

    static func pageview_newsletter_carousel(title: String) {
        Analytics.logEvent("pageview_newsletter_carousel", parameters: [
            "category": "pageview",
            "navigation": "newsletter_carousel",
            "object_type": "newsletter",
            "object_id": title
        ])
    }

    static func impression_newsletter_carousel(title: String, listIndex: Int) {
        let dataString = ["list_index": listIndex].toJSONString()
        Analytics.logEvent("impression_newsletter_carousel", parameters: [
            "category": "impression",
            "navigation": "newsletter_carousel",
            "object_section": "newsletter_card",
            "object_type": "newsletter",
            "object_id": title,
            "data": dataString ?? ""
        ])
    }

    static func click_newsletter_carousel(title: String, listIndex: Int) {
        let dataString = ["list_index": listIndex].toJSONString()
        Analytics.logEvent("click_newsletter_carousel", parameters: [
            "category": "click",
            "navigation": "newsletter_carousel",
            "object_section": "newsletter_card",
            "object_type": "button",
            "object_id": title,
            "data": dataString ?? ""
        ])
    }

    // MARK: - Bottom Sheet

    static func pageview_bottom_sheet_notification() {
        Analytics.logEvent("pageview_bottom_sheet_notification", parameters: [
            "category": "pageview",
            "navigation": "bottom_sheet_notification",
            "object_type": "bottom_sheet"
        ])
    }

    static func click_bottom_sheet_notification() {
        Analytics.logEvent("click_bottom_sheet_notification", parameters: [
            "category": "click",
            "navigation": "bottom_sheet_notification",
            "object_type": "button"
        ])
    }

    static func pageview_bottom_sheet_custom() {
        Analytics.logEvent("pageview_bottom_sheet_custom", parameters: [
            "category": "pageview",
            "navigation": "bottom_sheet_custom",
            "object_type": "bottom_sheet"
        ])
    }

    static func click_bottom_sheet_custom(userData: [String: Any]) {
        let dataString = userData.toJSONString()
        Analytics.logEvent("click_bottom_sheet_custom", parameters: [
            "category": "click",
            "navigation": "bottom_sheet_custom",
            "object_section": "bottom_sheet",
            "object_type": "button",
            "user_properties": dataString ?? ""
        ])
    }
}

