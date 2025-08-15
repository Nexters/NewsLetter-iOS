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
    @Binding var isLoading: Bool
    @Binding var isFail: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !isFail else { return }
        
        let request = URLRequest(url: url, timeoutInterval: 15)
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
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.isFail = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.currentURL = webView.url?.absoluteString ?? ""
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.isFail = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            parent.isLoading = false
            parent.isFail = true
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.currentURL = webView.url?.absoluteString ?? ""
        }
    }
}
