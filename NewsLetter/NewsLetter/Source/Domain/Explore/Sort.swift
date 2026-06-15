//
//  Sort.swift
//  NewsLetter
//
//  Created by 이원빈 on 6/15/26.
//

import Foundation

enum Sort: String, CaseIterable {
    case registered
    case published
    
    // 현재 case의 다음 case를 반환 (마지막이면 첫 번째로 순환)
    func next() -> Sort {
        let all = Sort.allCases
        let index = all.firstIndex(of: self)!
        let nextIndex = all.index(after: index)
        return nextIndex == all.endIndex ? all[0] : all[nextIndex]
    }
    
    func displayText() -> String {
        switch self {
        case .registered: return "등록순"
        case .published: return "발행순"
        }
    }
}
