//
//  JokeResponseDTO.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/16/25.
//

import Foundation

struct JokeResponseDTO: Decodable {
    let category: String
    let type: String
    let setup: String?
    let delivery: String?
    let joke: String?
}

/*
 MARK: 응답 케이스 예시
 [case 1]
 {
     "error": false,
     "category": "Dark",
     "type": "single",
     "joke": "My girlfriend's dog died, so I tried to cheer her up by getting her an identical one. It just made her more upset. She screamed at me, \"What am I supposed to do with two dead dogs?\"",
     "flags": {
         "nsfw": false,
         "religious": false,
         "political": false,
         "racist": false,
         "sexist": false,
         "explicit": false
     },
     "safe": false,
     "id": 274,
     "lang": "en"
 }
 
 [case 2]
 {
     "error": false,
     "category": "Pun",
     "type": "twopart",
     "setup": "The gas Argon walks into a bar.\nThe barkeeper says \"What would you like to drink?\"",
     "delivery": "But Argon doesn't react.",
     "flags": {
         "nsfw": false,
         "religious": false,
         "political": false,
         "racist": false,
         "sexist": false,
         "explicit": false
     },
     "id": 147,
     "safe": true,
     "lang": "en"
 }
 */
