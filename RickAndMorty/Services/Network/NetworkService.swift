//
//  NetworkService.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 21.11.2024.
//

import Foundation
import UIKit

typealias EpisodesResult = Result<([Episode], Int), RMError>
typealias CharacterResult = Result<Character, RMError>
typealias ImageResult = Result<UIImage, RMError>

protocol Networking {
    func getEpisodes(by category: SearchCategory, page: Int?) async throws -> EpisodesResult
    func getCharacter(id: Int) async throws -> CharacterResult
    func getImage(imagePath: String) async throws -> ImageResult
}

enum SearchCategory {
    case episodeNumber(query: String)
    case name(query: String)
    case all
}

class NetworkService: Networking {
    private let client: IHTTPClient

    init(dependencies: IDependencies) {
        self.client = dependencies.client
    }

    func getEpisodes(by category: SearchCategory, page: Int? = nil) async throws -> EpisodesResult {
        let result: HTTPResult

        switch category {
        case .episodeNumber(let episodeNumber):
            if !episodeNumber.isEmpty {
                result = await client.request(target: .episodesByEpisode(episodeNumber: episodeNumber))
            } else {
                result = await client.request(target: .episodes(page: page))
            }
        case .name(let name):
            if !name.isEmpty {
                result = await client.request(target: .episodesByName(name: name))
            } else {
                result = await client.request(target: .episodes(page: page))
            }
        default:
            result = await client.request(target: .episodes(page: page))
        }

        switch result {
        case .success(let data):
            do {
                let episodeInfo = try data.decoded() as EpisodeInfo
                return .success((episodeInfo.results, episodeInfo.info.pages))
            } catch {
                print(error)
                return .failure(.unableToDecode)
            }
        case .failure(let error):
            print(error)
            return .failure(error)
        }
    }
    
    func getCharacter(id: Int) async throws -> CharacterResult {
        let result = await client.request(target: .character(id: id))
        switch result {
        case .success(let data):
            do {
                let character = try data.decoded() as Character
                return .success(character)
            } catch {
                print(error)
                return .failure(.unableToDecode)
            }
        case .failure(let error):
            print(error)
            return .failure(error)
        }
    }

    func getImage(imagePath: String) async throws -> ImageResult {
        let result = await client.request(target: .image(imagePath: imagePath))
        switch result {
        case .success(let data):
            guard let image = UIImage(data: data) else {
                return .failure(.unableToDecode)
            }

            return .success(image)
        case .failure(let error):
            print(error)
            return .failure(error)
        }
    }
}
