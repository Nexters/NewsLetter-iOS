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
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        reloadTrigger.toggle()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    Spacer()
                    Text(currentURL.isEmpty ? url.absoluteString : currentURL)
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
                            .foregroundColor(.black)
                            .padding(8)
                    }
                }
                .frame(height: 44)
                .background(Color.white.opacity(0.95))
                .padding(.top, 40)
                .padding(.horizontal, 12)
                
                WebView(url: url, reloadTrigger: reloadTrigger, currentURL: $currentURL)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
