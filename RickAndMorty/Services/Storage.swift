//
//  Storage.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 26.11.2024.
//

import Foundation

final class Storage {

    var episodes: [EpisodeFull] = []

    private lazy var favouriteEpisodes: [EpisodeFull] = {
        return self.episodes.filter({ $0.isFavourite })
    }() {
        didSet {
            print("Saved to local storage")
            saveFavourites()
        }
    }

    func addFavourite(by episodeId: Int) {
        episodes.first(where: { $0.id == episodeId })?.isFavourite = true
    }

    func removeFavourite(by episodeId: Int) {
        episodes.first(where: { $0.id == episodeId })?.isFavourite = false
    }

    func getFavouriteEpisodes() -> [EpisodeFull] {
        episodes.filter({ $0.isFavourite })
    }

    private func saveFavourites() {
        // Save to local storage
    }

    func reset() {
        favouriteEpisodes = []
    }
}
