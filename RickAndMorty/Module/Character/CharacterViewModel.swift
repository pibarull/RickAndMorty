//
//  CharacterViewModel.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 10.12.2024.
//

import Foundation

final class CharacterViewModel {

    typealias CellData = (String, String)
    // Private
    private let storage: Storage

    // Public
    var character: CharacterFull
    var cellData: [CellData] {
        getCellData(from: character)
    }

    init(dependencies: IDependencies, character: CharacterFull) {
        self.storage = dependencies.storage
        self.character = character
    }

    private func getCellData(from character: CharacterFull) -> [CellData] {
        var cellData: [CellData] = []

        cellData.append(("Gender", character.gender))
        cellData.append(("Status", character.status))
        cellData.append(("Specie", character.species))
        cellData.append(("Origin", character.origin.name))
        cellData.append(("Type", character.type.isEmpty ? "Unknown" : character.type))
        cellData.append(("Location", character.location.name))

        return cellData
    }

    func updateCharacterPhoto(with image: Data) {
        storage.updatePhoto(for: character.id, with: image)
    }
}
