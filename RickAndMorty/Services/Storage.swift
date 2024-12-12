//
//  Storage.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 26.11.2024.
//

import Foundation

final class Storage {


    var episodes: [EpisodeFull] = []

    private var favouriteEpisodes: [EpisodeFull] = [] {
        didSet {
            print("Saved to local storage")
            saveFavourites()
        }
    }
    private let favouriteEpisodesKey = "favourite-episodes"

    init() {
        self.favouriteEpisodes = fetchFavourites()
    }

    func addFavourite(by episodeId: Int) {
        episodes.first(where: { $0.id == episodeId })?.isFavourite = true
        if !favouriteEpisodes.contains(where: { $0.id == episodeId }) {
            favouriteEpisodes.append(contentsOf: episodes.filter({ $0.id == episodeId }))
        }
    }

    func removeFavourite(by episodeId: Int) {
        episodes.first(where: { $0.id == episodeId })?.isFavourite = false
        favouriteEpisodes.removeAll(where: { $0.id == episodeId })
    }

    func getFavouriteEpisodes() -> [EpisodeFull] {
        return favouriteEpisodes
    }

    private func fetchFavourites() -> [EpisodeFull] {
        if let data = UserDefaults.standard.data(forKey: favouriteEpisodesKey) {
            do {
                let favouriteEpisodes = try data.decoded() as [EpisodeFull]
                return favouriteEpisodes
            } catch {
                print("Unable to Decode EpisodeFull (\(error))")
                return []
            }
        } else {
            return []
        }
    }

    private func saveFavourites() {
        // Save to local storage
        do {
            let data = try JSONEncoder().encode(favouriteEpisodes)
            UserDefaults.standard.set(data, forKey: favouriteEpisodesKey)
        } catch {
            print("Unable to Encode Array of EpisodeFull (\(error))")
        }
    }

    func reset() {
        episodes = []
        UserDefaults.standard.removeObject(forKey: favouriteEpisodesKey)
    }
}
