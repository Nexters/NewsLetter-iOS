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
}

enum SortDirection: String, CaseIterable {
    case asc
    case desc
    
    // 현재 case의 다음 case를 반환 (마지막이면 첫 번째로 순환)
    func next() -> Self {
        let all = SortDirection.allCases
        let index = all.firstIndex(of: self)!
        let nextIndex = all.index(after: index)
        return nextIndex == all.endIndex ? all[0] : all[nextIndex]
    }
    
    func displayText() -> String {
        switch self {
        case .asc: return "오래된순"
        case .desc: return "최신순"
        }
    }
}
