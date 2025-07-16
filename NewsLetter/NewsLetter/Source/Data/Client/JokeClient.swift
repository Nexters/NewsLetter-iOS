//
//  JokeClient.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/16/25.
//

import Combine

import ComposableArchitecture
import Moya

@DependencyClient
struct JokeClient {
    static let apiClient = MoyaAPIClient()
    
    var fetchJoke: () -> AnyPublisher<Joke, APIError> = {
        Fail(error: APIError.unknown)
            .eraseToAnyPublisher()
    }
}

extension DependencyValues {
    var jokeClient: JokeClient {
        get { self[JokeClient.self] }
        set { self[JokeClient.self] = newValue }
    }
}

extension JokeClient: DependencyKey {
    static var liveValue: JokeClient = {
       return JokeClient(
        fetchJoke: {
            apiClient.request(JokeAPI.fetchAnyJokes, as: JokeResponseDTO.self)
                .map { dto in
                    /// API 응답 케이스는 크게 두 가지로 나뉜다:
                    /// case 1 :  joke 로 내려오는 경우(이때 setup, delivery 는 nil))
                    /// case 2 : setup, delivery 로 내려오는 경우(이때 joke 는 nil)
                    if let joke = dto.joke {
                        return Joke(setup: "no setup", delivery: joke) /// case 1
                    } else {
                        return Joke(setup: dto.setup ?? "", delivery: dto.delivery ?? "") /// case 2
                    }
                }
                .eraseToAnyPublisher()
        }
       )
    }()
    
    static var previewValue: JokeClient = {
        return JokeClient(
            fetchJoke: {
                Just(Joke(setup: "preview_setup", delivery: "preview_delivery"))
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            }
        )
    }()
    
    static var testValue: JokeClient = previewValue
}
