//
//  KakapShareManager.swift
//  NewsLetter
//
//  Created by 이조은 on 10/7/25.
//

import Foundation
import SwiftUI
import UIKit

import KakaoSDKTemplate
import KakaoSDKShare

@MainActor
final class KakaoShareManager: ObservableObject {
    @Published var errorMessage = ""

    private let cardClient: CardClient

    init(cardClient: CardClient = CardClient.liveValue) {
        self.cardClient = cardClient
    }

    func shareToKakao(title: String, id: Int, textColor: Color, contentURL: String) async {
        let dto = OGShareURLRequestDTO(exposureContentId: Int64(id), textColor: textColor.toHexString)
        let ogImageURLString = cardClient.fetchOGShareURL(dto)

        guard let ogImageURL = URL(string: ogImageURLString) else {
            errorMessage = "OG 이미지 URL이 잘못되었습니다."
            return
        }

        let content = Content(
            title: title,
            imageUrl: ogImageURL,
            imageWidth: 800,
            imageHeight: 400,
            description: "쏙 - 매일 뉴스레터 6개를 한눈에",
            link: Link(iosExecutionParams: [:])
        )

        let buttons = [
            Button(
                title: "앱으로 보기",
                link: Link(
                    iosExecutionParams: [:]
                )
            )
        ]

        let template = FeedTemplate(content: content, buttons: buttons)

        if ShareApi.isKakaoTalkSharingAvailable() {
            ShareApi.shared.shareDefault(templatable: template) { result, error in
                if let error = error {
                    print("❌ 공유 실패: \(error)")
                    return
                }

                if let url = result {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url.url, options: [:], completionHandler: nil)
                    }
                }
            }
        } else {
            if let url = ShareApi.shared.makeDefaultUrl(templatable: template) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                errorMessage = "❌ 공유 URL 생성에 실패했습니다."
            }
        }
    }
}
