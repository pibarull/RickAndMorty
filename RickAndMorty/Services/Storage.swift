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

    // Private
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

    // Public
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

    func updatePhoto(for characterId: Int, with image: Data) {
        let episodesToUpdate = episodes.filter{ $0.selectedCharacter?.id == characterId }
        episodesToUpdate.forEach { episode in
            if let character = episode.selectedCharacter, let image = image.image {
                let updatedCharacter = CharacterFull(character: character, image: image)
                episode.selectedCharacter = updatedCharacter
            }
        }
        let favouriteEpisodesToUpdate = favouriteEpisodes.filter{ $0.selectedCharacter?.id == characterId }
        favouriteEpisodesToUpdate.forEach { episode in
            if let character = episode.selectedCharacter, let image = image.image {
                let updatedCharacter = CharacterFull(character: character, image: image)
                episode.selectedCharacter = updatedCharacter
            }
        }
    }

    func reset() {
        episodes = []
        UserDefaults.standard.removeObject(forKey: favouriteEpisodesKey)
    }
}
