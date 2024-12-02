//
//  EpisodesAssembly.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit

final class EpisodesAssembly {
    static func configure(_ dependencies: IDependencies) -> UIViewController {
        return dependencies.container.getEpisodesViewController()
    }
}
