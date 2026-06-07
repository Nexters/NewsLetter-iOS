//
//  AnalyticsManager.swift
//  NewsLetter
//
//  Created by 이조은 on 9/28/25.
//

import Foundation

import FirebaseAnalytics

enum GA {

    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Main

    static func main_pageview() {
        guard !isPreview else { return }
        Analytics.logEvent("main_pageview", parameters: [
            "navigation": "main",
            "event": "pageview"
        ])
    }

    static func main_contents_detail_pageview(
        cardIndex: Int,
        cardType: String,
        contentType: String,
        contentTitle: String,
        contentId: Int
    ) {
        guard !isPreview else { return }
        Analytics.logEvent("main_contents_detail_pageview", parameters: [
            "navigation": "main_contents_detail",
            "event": "pageview",
            "card_index": cardIndex,
            "card_type": cardType,
            "content_type": contentType,
            "content_title": contentTitle,
            "content_id": contentId
        ])
    }

    static func main_contents_detail_click(
        cardType: String,
        contentType: String,
        contentTitle: String,
        contentId: Int
    ) {
        guard !isPreview else { return }
        Analytics.logEvent("main_contents_detail_click", parameters: [
            "navigation": "main_contents_detail",
            "event": "click",
            "card_type": cardType,
            "content_type": contentType,
            "content_title": contentTitle,
            "content_id": contentId
        ])
    }

    // MARK: - Explore

    static func explore_pageview() {
        guard !isPreview else { return }
        Analytics.logEvent("explore_pageview", parameters: [
            "navigation": "explore",
            "event": "pageview"
        ])
    }

    static func explore_contents_detail_pageview(
        cardIndex: Int,
        contentType: String,
        contentTitle: String,
        contentId: Int
    ) {
        guard !isPreview else { return }
        Analytics.logEvent("explore_contents_detail_pageview", parameters: [
            "navigation": "explore_contents_detail",
            "event": "pageview",
            "card_index": cardIndex,
            "content_type": contentType,
            "content_title": contentTitle,
            "content_id": contentId
        ])
    }

    static func explore_contents_detail_click(
        contentType: String,
        contentTitle: String,
        contentId: Int
    ) {
        guard !isPreview else { return }
        Analytics.logEvent("explore_contents_detail_click", parameters: [
            "navigation": "explore_contents_detail",
            "event": "click",
            "content_type": contentType,
            "content_title": contentTitle,
            "content_id": contentId
        ])
    }

    static func explore_click_order(orderBy: String) {
        guard !isPreview else { return }
        Analytics.logEvent("explore_click", parameters: [
            "navigation": "explore",
            "event": "click",
            "action_type": "order",
            "order_by": orderBy
        ])
    }

    static func explore_click_filter(filterValue: String) {
        guard !isPreview else { return }
        Analytics.logEvent("explore_click", parameters: [
            "navigation": "explore",
            "event": "click",
            "action_type": "filter",
            "filter_value": filterValue
        ])
    }

    static func explore_report_pageview() {
        guard !isPreview else { return }
        Analytics.logEvent("explore_report_pageview", parameters: [
            "navigation": "explore_report",
            "event": "pageview"
        ])
    }

    static func explore_report_click(
        name: String,
        url: String,
        jobGroup: String,
        language: String
    ) {
        guard !isPreview else { return }
        Analytics.logEvent("explore_report_click", parameters: [
            "navigation": "explore_report",
            "event": "click",
            "action_type": "submit_report_form",
            "name": name,
            "url": url,
            "job_group": jobGroup,
            "language": language
        ])
    }

    // MARK: - Bottom Sheet

    static func pageview_bottom_sheet_notification() {
        guard !isPreview else { return }
        Analytics.logEvent("bottom_sheet_notification_pageview", parameters: [
            "navigation": "bottom_sheet_notification",
            "event": "pageview"
        ])
    }

    static func click_bottom_sheet_notification() {
        guard !isPreview else { return }
        Analytics.logEvent("bottom_sheet_notification_click", parameters: [
            "navigation": "bottom_sheet_notification",
            "event": "click"
        ])
    }

    static func pageview_bottom_sheet_custom() {
        guard !isPreview else { return }
        Analytics.logEvent("bottom_sheet_custom_pageview", parameters: [
            "navigation": "bottom_sheet_custom",
            "event": "pageview"
        ])
    }

    static func click_bottom_sheet_custom(userData: [String: Any]) {
        guard !isPreview else { return }
        let dataString = userData.toJSONString()
        Analytics.logEvent("bottom_sheet_custom_click", parameters: [
            "navigation": "bottom_sheet_custom",
            "event": "click",
            "user_properties": dataString ?? ""
        ])
    }
}

extension Card.Kind {
    var gaContentType: String {
        switch self {
        case .news: return "newsletter"
        case .blog: return "blog"
        case .book: return "book"
        }
    }
}
