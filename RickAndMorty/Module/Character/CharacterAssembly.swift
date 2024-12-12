//
//  CharacterAssembly.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit

final class CharacterAssembly {
    static func configure(_ dependencies: IDependencies, character: CharacterFull) -> UIViewController {
        return dependencies.container.getCharacterViewController(character: character)
    }
}
