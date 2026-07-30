//
//  UserResponseDTO.swift
//  NewsLetter
//

import Foundation

struct UserResponseDTO: Decodable {
    let id: Int
    let preferences: [Preference]
    /// 아직 경력을 선택하지 않은 유저는 서버가 null로 내려줍니다.
    let workingExperience: WorkingExperience?
    let isOnboarded: Bool
    let isCategoryChanged: Bool
    let categoryChangeCount: Int

    init(
        id: Int,
        preferences: [Preference],
        workingExperience: WorkingExperience?,
        isOnboarded: Bool,
        isCategoryChanged: Bool,
        categoryChangeCount: Int
    ) {
        self.id = id
        self.preferences = preferences
        self.workingExperience = workingExperience
        self.isOnboarded = isOnboarded
        self.isCategoryChanged = isCategoryChanged
        self.categoryChangeCount = categoryChangeCount
    }

    // 서버가 아직 내려주지 않거나 null일 수 있는 필드 때문에 디코딩 자체가 실패해 바텀시트가 조용히 안 뜨는 일이 없도록,
    // 신규/선택 필드는 없거나 null이면 안전한 기본값으로 채웁니다.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        preferences = try container.decode([Preference].self, forKey: .preferences)
        workingExperience = try container.decodeIfPresent(WorkingExperience.self, forKey: .workingExperience)
        isOnboarded = try container.decodeIfPresent(Bool.self, forKey: .isOnboarded) ?? false
        isCategoryChanged = try container.decodeIfPresent(Bool.self, forKey: .isCategoryChanged) ?? true
        categoryChangeCount = try container.decodeIfPresent(Int.self, forKey: .categoryChangeCount) ?? 0
    }

    private enum CodingKeys: String, CodingKey {
        case id, preferences, workingExperience, isOnboarded, isCategoryChanged, categoryChangeCount
    }
}
