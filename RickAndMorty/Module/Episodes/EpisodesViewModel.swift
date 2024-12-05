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
    lazy var episodes: [EpisodeFull] = []
    lazy var favouriteEpisodes: [EpisodeFull] = {
        storage.getFavouriteEpisodes()
    }()
    let state = BehaviorRelay<State>(value: .loading)
    var totalPages = 1
    var currentPage = 1

    init(dependencies: IDependencies) {
        self.networkService = dependencies.networkService
        self.storage = dependencies.storage
    }

    func getFavouriteEpisodes() {
        favouriteEpisodes = storage.getFavouriteEpisodes()
    }

    func getEpisodes(by category: SearchCategory, page: Int? = nil) async {
        do {
            let result = try await networkService.getEpisodes(by: category, page: page)
            switch result {
            case .success(let data):
                let episodes = data.0
                let totalPages = data.1

                let charactersFetched = try await getCharacters(for: episodes)
                let imagesFetched = try await loadImages(for: charactersFetched)

                buildEpisodes(charactersFetched: charactersFetched,
                              imagesFetched: imagesFetched,
                              episodes: episodes)

                // TODO: use single source for episodes - from Storage
//                storage.episodes = self.episodes
                self.episodes = storage.episodes
                self.totalPages = totalPages
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

        let newEpisodes = episodes.map({
            let episode = EpisodeFull(id: $0.id,
                                      name: $0.name,
                                      episode: $0.episode,
                                      characters: $0.characters,
                                      url: $0.url,
                                      created: $0.created,
                                      selectedCharacter: nil)
            return episode
        })

//        storage.episodes.append(contentsOf: newEpisodes)

        if characters.count == newEpisodes.count {
            for i in 0..<newEpisodes.count {
                if let selectedImage = imagesFetched["\(characters[i].imagePath)"] {
                    let selectedCharacter = CharacterFull(character: characters[i], image: selectedImage ?? UIImage())
                    newEpisodes[i].selectedCharacter = selectedCharacter
                }
            }

            storage.episodes.append(contentsOf: newEpisodes)
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
