//
//  Episode.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 19.11.2024.
//

import Foundation

struct Episode: Decodable, Identifiable {
    let id: Int
    let name: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}

class EpisodeFull: Hashable {

    static func == (lhs: EpisodeFull, rhs: EpisodeFull) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.episode == rhs.episode &&
        lhs.characters == rhs.characters &&
        lhs.url == rhs.url &&
        lhs.created == rhs.created &&
        lhs.selectedCharacter == rhs.selectedCharacter &&
        lhs.isFavourite == rhs.isFavourite
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(episode)
        hasher.combine(characters)
        hasher.combine(url)
        hasher.combine(created)
        hasher.combine(selectedCharacter)
        hasher.combine(isFavourite)
    }

    var id: Int = 0
    var name: String = ""
    var episode: String  = ""
    var characters: [String] = []
    var url: String = ""
    var created: String = ""
    var selectedCharacter: CharacterFull?
    var isFavourite: Bool = false

    init(id: Int, name: String, episode: String, characters: [String], url: String, created: String, selectedCharacter: CharacterFull?) {
        self.id = id
        self.name = name
        self.episode = episode
        self.characters = characters
        self.url = url
        self.created = created
        self.selectedCharacter = selectedCharacter
    }

    // Workaround for handling errors
    convenience init(id: Int) {
        self.init(id: id, name: "", episode: "", characters: [], url: "", created: "", selectedCharacter: nil)
    }
}
