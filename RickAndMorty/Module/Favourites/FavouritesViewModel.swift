//
//  FavouritesViewModel.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 27.11.2024.
//

import Foundation

final class FavouritesViewModel {

    private let storage: Storage

    lazy var favouriteEpisodes: [EpisodeFull] = {
        self.storage.getFavouriteEpisodes()
    }()

    init(dependencies: IDependencies) {
        self.storage = dependencies.storage
    }
}
