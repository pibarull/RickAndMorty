//
//  LaunchCoordinator.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 16.11.2024.
//

import UIKit

class LaunchCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var dependencies: IDependencies

    init(_ navigationController: UINavigationController, dependencies: IDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        showLaunchViewController()
    }

    func showLaunchViewController() {
        let launchViewController = LaunchAssembly.configure(dependencies)
        if let launchViewController = launchViewController as? LaunchViewController {
            launchViewController.didFinishAnimation = { [weak self] in
                self?.finish()
            }
        }
        navigationController.show(launchViewController, sender: self)
    }
}
