//
//  FavouritesAssembly.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit

final class FavouritesAssembly {
    static func configure(_ dependencies: IDependencies) -> UIViewController {
        return dependencies.container.getFavouritesViewController()
    }
}
