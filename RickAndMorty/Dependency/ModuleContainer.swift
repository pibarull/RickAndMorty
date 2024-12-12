//
//  ModuleContainer.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 17.11.2024.
//

import UIKit

protocol IModuleContainer {
    func getLaunchViewController() -> UIViewController
    func getTabBarController() -> UIViewController
    func getEpisodesViewController() -> UIViewController
    func getCharacterViewController(character: CharacterFull) -> UIViewController
    func getFavouritesViewController() -> UIViewController
}

final class ModuleContainer: IModuleContainer {
    private let dependencies: IDependencies
    required init(_ dependencies: IDependencies) {
        self.dependencies = dependencies
    }
}

extension ModuleContainer {

    func getLaunchViewController() -> UIViewController {
        return LaunchViewController()
    }

    func getTabBarController() -> UIViewController {
        let tabBarController = TabBarController()
        var viewControllers: [UIViewController] = []
        let episodesViewController = EpisodesAssembly.configure(dependencies)
        let favouritesViewController = FavouritesAssembly.configure(dependencies)

        episodesViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        episodesViewController.tabBarItem.tag = 0

        favouritesViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "favouritesIcon"), selectedImage: UIImage(named: "favouritesIconSelected"))
        favouritesViewController.tabBarItem.tag = 1

        viewControllers.append(UINavigationController(rootViewController: episodesViewController))
        viewControllers.append(UINavigationController(rootViewController: favouritesViewController))
        tabBarController.viewControllers = viewControllers
        tabBarController.viewControllers?.forEach({ vc in
            if vc.tabBarItem.tag == 0 {
                vc.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 50, bottom: -10, right: -50)
            } else {
                vc.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: -50, bottom: -10, right: 50)
            }
        })

        return tabBarController
    }

    func getEpisodesViewController() -> UIViewController {
        let viewModel = EpisodesViewModel(dependencies: dependencies)
        return EpisodesViewController(viewModel: viewModel)
    }

    func getCharacterViewController(character: CharacterFull) -> UIViewController {
        let viewModel = CharacterViewModel(dependencies: dependencies, character: character)
        return CharacterViewController(viewModel: viewModel)
    }

    func getFavouritesViewController() -> UIViewController {
        let viewModel = EpisodesViewModel(dependencies: dependencies)
        return FavouritesViewController(viewModel: viewModel)
    }
}
