//
//  NewsLetterApp.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/12/25.
//

import SwiftUI

import ComposableArchitecture

@main
struct NewsLetterApp: App {
    let store = Store(initialState: AppReducer.State()) { AppReducer() }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
