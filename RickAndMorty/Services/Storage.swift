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
//        if var episode = episodes.first(where: { $0.id == episodeId }) {
//            episode.isFavourite = true
////            favouriteEpisodes.append(episode)
//        }
    }

    func removeFavourite(by episodeId: Int) {
        episodes.first(where: { $0.id == episodeId })?.isFavourite = false
//        if var episode = episodes.first(where: { $0.id == episodeId }) {
//            episode.isFavourite = false
//        }
//        favouriteEpisodes.removeAll(where: { $0.id == episodeId })
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
