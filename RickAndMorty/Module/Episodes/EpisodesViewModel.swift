//
//  EpisodesViewModel.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 21.11.2024.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

final class EpisodesViewModel {

    enum State {
        case loading
        case loaded
        case error(_ value: RMError)
    }
    
    // Private
    private let networkService: NetworkService
    private let storage: Storage

    // Public
    var episodes: [EpisodeFull] = []
    lazy var favouriteEpisodes: [EpisodeFull] = {
        storage.getFavouriteEpisodes()
    }()
    let state = BehaviorRelay<State>(value: .loading)

    init(dependencies: IDependencies) {
        self.networkService = dependencies.networkService
        self.storage = dependencies.storage
    }

    func getFavouriteEpisodes() {
//        episodes = storage.getFavouriteEpisodes()
        favouriteEpisodes = storage.getFavouriteEpisodes()
    }

    func getEpisodes(byEpisode episodeNumber: String = "", byName name: String = "") async {
        do {
            let result = try await networkService.getEpisodes(byEpisode: episodeNumber, byName: name)
            switch result {
            case .success(let episodes):
                let charactersFetched = try await getCharacters(for: episodes)
                let imagesFetched = try await loadImages(for: charactersFetched)

                buildEpisodes(charactersFetched: charactersFetched,
                              imagesFetched: imagesFetched,
                              episodes: episodes)

                // TODO: use single source for episodes - from Storage
                storage.episodes = self.episodes
                state.accept(.loaded)
            case .failure(let error):
                //Show error alert
                self.episodes = [.init(id: -404)]
                state.accept(.error(error))
            }
        } catch {
            //Show error alert
            self.episodes = [.init(id: -404)]
            state.accept(.error(.apiError(error: error)))
        }
    }

    private func buildEpisodes(charactersFetched: [Character?], imagesFetched: [String: UIImage?], episodes: [Episode]) {
        guard charactersFetched.contains(where: { $0 != nil }),
              imagesFetched.contains(where: { $0.value != nil }) else { return }

        let characters = charactersFetched.compactMap { $0 }

        self.episodes = episodes.map({
            let episode = EpisodeFull(id: $0.id,
                                      name: $0.name,
                                      episode: $0.episode,
                                      characters: $0.characters,
                                      url: $0.url,
                                      created: $0.created,
                                      selectedCharacter: nil)
            return episode
        })

        if characters.count == self.episodes.count {
            for i in 0..<self.episodes.count {
                if let selectedImage = imagesFetched["\(characters[i].imagePath)"] {
                    let selectedCharacter = CharacterFull(character: characters[i], image: selectedImage ?? UIImage())
                    self.episodes[i].selectedCharacter = selectedCharacter
                }
            }
        } else {
            //Show error message that not all data fetched
        }
    }

    private func getCharacters(for episodes: [Episode]) async throws -> [Character?] {
        try await withThrowingTaskGroup(of: Character?.self) { group in
            episodes.enumerated().forEach { (episodeIndex, episode) in
                if let selectedCharacter = episode.characters.randomElement(),
                   let index = selectedCharacter.lastIndex(of: "/"),
                   let id = Int(String(selectedCharacter.suffix(from: index).dropFirst())) {
                    group.addTask {
                        let character = try await self.getCharacter(id: id, for: episodeIndex)
                        return character
                    }
                }
            }

            var characters: [Character?] = []

            for try await character in group {
                characters.append(character)
            }

            return characters
        }
    }

    private func getCharacter(id: Int, for episodeIndex: Int) async throws -> Character? {
        do {
            let result = try await networkService.getCharacter(id: id)

            switch result {
            case .success(let character):
                return character
            case .failure(let error):
                //Show error alert
                state.accept(.error(error))
                return nil
            }
        } catch {
            //Show error alert
            state.accept(.error(.apiError(error: error)))
            return nil
        }
    }

    private func loadImages(for characters: [Character?]) async throws -> [String: UIImage?] {
        try await withThrowingTaskGroup(of: (String?, UIImage?).self) { group in
            var images: [String: UIImage?] = [:]

            characters.forEach { character in
                group.addTask {
                    let image = try await self.loadImage(by: character?.imagePath ?? "")
                    return (character?.imagePath, image)
                }
            }

            for try await (imagePath, image) in group {
                if let imagePath = imagePath {
                    images[imagePath] = image
                }
            }

            return images
        }
    }

    private func loadImage(by imagePath: String) async throws -> UIImage? {
        do {
            let result = try await networkService.getImage(imagePath: imagePath)

            switch result {
            case .success(let image):
                return image
            case .failure(let error):
                //Show error alert
                state.accept(.error(error))
                return nil
            }
        } catch {
            //Show error alert
            state.accept(.error(.apiError(error: error)))
            return nil
        }
    }

    func addFavourite(episodeId: Int) {
        storage.addFavourite(by: episodeId)
    }

    func removeFavourite(episodeId: Int) {
        storage.removeFavourite(by: episodeId)
    }
}
