//
//  EpisodeInfo.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 19.11.2024.
//

import Foundation

struct EpisodeInfo: Decodable {
    let info: Info
    let results: [Episode]
}

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
