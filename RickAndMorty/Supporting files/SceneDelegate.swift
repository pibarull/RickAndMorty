//
//  SceneDelegate.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 16.11.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: AppCoordinator?
    private var dependencies: IDependencies = Dependencies()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let navigationController = UINavigationController()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController?.modalPresentationStyle = .fullScreen
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        coordinator = AppCoordinator(navigationController, dependencies: dependencies)
        coordinator?.start()
    }
}

