//
//  AppCoordinator.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 16.11.2024.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var dependencies: IDependencies
    
    init(_ navigationController: UINavigationController, dependencies: IDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        showLaunchFlow()
    }

    func showLaunchFlow() {
        let launchCoordinator = LaunchCoordinator(navigationController, dependencies: dependencies)
        launchCoordinator.finishDelegate = self
        launchCoordinator.start()
        childCoordinators.append(launchCoordinator)
    }

    func showMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController, dependencies: dependencies)
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {

    func coordinatorDidFinish(childCoordinator: Coordinator) {
        if childCoordinators.count == 1 && childCoordinators.first is LaunchCoordinator {
            showMainFlow()
        }
    }
}
