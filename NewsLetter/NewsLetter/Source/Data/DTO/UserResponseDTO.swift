//
//  UserResponseDTO.swift
//  NewsLetter
//

import Foundation

struct UserResponseDTO: Decodable {
    let id: Int
    let preferences: [Preference]
    let workingExperience: WorkingExperience
}
