//
//  RickAndMortyAPI.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 19.11.2024.
//

import Foundation

enum RmAPI {
    case episodes
    case episodesByEpisode(episodeNumber: String)
    case episodesByName(name: String)
    case character(id: Int)
    case image(imagePath: String)
}

extension RmAPI {

    var baseURL: URL {
//        print((Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String))
//        guard let url = URL(string: (Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String) ?? "https://rickandmortyapi.com/api") else { fatalError() }
        guard let url = URL(string: "https://rickandmortyapi.com/api") else { fatalError() }
        return url
    }

    var path: String {
        switch self {
        case .episodes:
            return "/episode"
        case .episodesByEpisode(let episodeNumber):
            return "/episode/?episode=\(episodeNumber)"
        case .episodesByName(let name):
            return "/episode/?name=\(name)"
        case .character(let id):
            return "/character/\(id)"
        case .image(let imagePath):
            return imagePath
        }
    }

    var method: String {
        switch self {
        case .episodes,
             .episodesByEpisode,
             .episodesByName,
             .character,
             .image:
            return "GET"
        }
    }

    var request: URLRequest? {
        let url: URL?

        switch self {
        case .image(_):
            url = URL(string: path)
        default:
            url = URL(string: "\(baseURL)\(path)")
        }

        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}
