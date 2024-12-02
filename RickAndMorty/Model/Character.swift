//
//  Character.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 19.11.2024.
//

import Foundation
import UIKit

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: CharacterOrigin
    let location: CharacterLocation
    let imagePath: String
    let episode: [String]
    let url: String
    let created: String

    enum CodingKeys: String, CodingKey {
        case id, name, status, species, type, gender, origin, location, episode, url, created
        case imagePath = "image"
    }
}

struct CharacterFull: Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: CharacterOrigin
    let location: CharacterLocation
    let episode: [String]
    let url: String
    let created: String
    let image: UIImage

    init(character: Character, image: UIImage) {
        self.id = character.id
        self.name = character.name
        self.status = character.status
        self.species = character.species
        self.type = character.type
        self.gender = character.gender
        self.origin = character.origin
        self.location = character.location
        self.episode = character.episode
        self.url = character.url
        self.created = character.created
        self.image = image
    }
}

struct CharacterLocation: Decodable, Hashable {
    let name: String
    let url: String
}

struct CharacterOrigin: Decodable, Hashable {
    let name: String
    let url: String
}
