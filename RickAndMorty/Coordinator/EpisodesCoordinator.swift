////
////  EpisodesCoordinator.swift
////  RickAndMorty
////
////  Created by Ilia Ershov on 18.11.2024.
////
//
//import UIKit
//
//class EpisodesCoordinator: Coordinator {
//    weak var finishDelegate: CoordinatorFinishDelegate?
//    var childCoordinators: [Coordinator] = []
//    var navigationController: UINavigationController
//    var dependencies: IDependencies
//
//    init(_ navigationController: UINavigationController, dependencies: IDependencies) {
//        self.navigationController = navigationController
//        self.dependencies = dependencies
//    }
//
//    func start() {
//        showEpisodesViewController()
//    }
//
//    // ????
//    func showEpisodesViewController() {
//        let episodesViewController = EpisodesAssembly.configure(dependencies)
//        if let episodesViewController = episodesViewController as? EpisodesViewController {
//            episodesViewController.openedCharacterDetails = { [weak self] character in
//                self?.showCharacterViewController(for: character)
//            }
//        }
//        navigationController.show(episodesViewController, sender: self)
//    }
//
//    func showCharacterViewController(for character: CharacterFull) {
//        let characterViewController = CharacterAssembly.configure(dependencies)
//        if let characterViewController = characterViewController as? CharacterViewController {
//            characterViewController.dismiss = { [weak self] in
//                self?.finish()
//            }
//        }
//        navigationController.show(characterViewController, sender: self)
//    }
//}
//
