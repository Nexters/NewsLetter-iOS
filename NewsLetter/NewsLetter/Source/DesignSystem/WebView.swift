//
//  WebView.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/6/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    var reloadTrigger: Bool = false
    @Binding var currentURL: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        if reloadTrigger {
            uiView.reload()
        } else if uiView.url == nil {
            uiView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.currentURL = webView.url?.absoluteString ?? ""
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.currentURL = webView.url?.absoluteString ?? ""
        }
    }
}
