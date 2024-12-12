//
//  TabBarCoordinator.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit

class TabBarCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var dependencies: IDependencies

    init(_ navigationController: UINavigationController, dependencies: IDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        showTabBarController()
    }

    func showTabBarController() {
        let tabBarController = TabBarAssembly.configure(dependencies)
        if let tabBarController = tabBarController as? TabBarController {
            
            tabBarController.viewControllers?.forEach({ vc in
                if let navVC = vc as? UINavigationController {
                    if let episodesViewController = navVC.viewControllers.first as? EpisodesViewController {
                        episodesViewController.openedCharacterDetails = { [weak self] character in
                            self?.showCharacterViewController(for: character, from: navVC)
                        }
                    } else if let favouritesViewController = navVC.viewControllers.first as? FavouritesViewController {
                        favouritesViewController.openedCharacterDetails = { [weak self] character in
                            self?.showCharacterViewController(for: character, from: navVC)
                        }
                    }
                }
            })
        }

        let navVC = UINavigationController(rootViewController: tabBarController)
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.selectedIndex = 0
            tabBarController.selectedViewController = tabBarController.viewControllers?[0]
            tabBarController.delegate?.tabBarController?(tabBarController, didSelect: tabBarController.viewControllers![0])
        }

        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            window.makeKeyAndVisible()
            window.rootViewController = navVC
            UIView.transition(with: window, duration: 1.0, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        } else {
            navVC.modalPresentationStyle = .fullScreen
            navigationController.showDetailViewController(navVC, sender: self)
        }
    }

    func showCharacterViewController(for character: CharacterFull, from navigationController: UINavigationController) {
        let characterViewController = CharacterAssembly.configure(dependencies, character: character)
        if let characterViewController = characterViewController as? CharacterViewController {
            characterViewController.dismiss = { [weak self] in
                navigationController.popViewController(animated: true)
                self?.finish()
            }
        }
        navigationController.show(characterViewController, sender: self)
    }
}
