//
//  WebViewFullScreen.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/6/25.
//

import SwiftUI

struct WebViewFullScreen: View {
    let url: URL
    @Binding var isPresented: Bool
    @State private var reloadTrigger: Bool = false
    @State private var currentURL: String = ""
    @State private var isLoading: Bool = false
    @State private var isFail: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        reloadTrigger.toggle()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .fontRangeLimited()
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    Spacer()
                    Text(currentURL.isEmpty ? url.absoluteString : currentURL)
                        .fontRangeLimited()
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .fontRangeLimited()
                            .foregroundColor(.black)
                            .padding(8)
                    }
                }
                .frame(height: 44)
                .background(Color.white.opacity(0.95))
                .padding(.top, 40)
                .padding(.horizontal, 12)
                
                if !isFail {
                    WebView(
                        url: url,
                        reloadTrigger: reloadTrigger,
                        currentURL: $currentURL,
                        isLoading: $isLoading,
                        isFail: $isFail
                    )
                    .edgesIgnoringSafeArea(.bottom)
                } else {
                    Spacer()
                    Text("페이지를 불러오는데 실패했습니다.\n다시 시도해주세요.") // TODO: Error UI 구성 필요
                    Spacer()
                }
            }
            if isLoading {
                ProgressView()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
