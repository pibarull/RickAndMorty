//
//  LaunchAssembly.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 17.11.2024.
//

import UIKit

final class LaunchAssembly {
    static func configure(_ dependencies: IDependencies) -> UIViewController {
        return dependencies.container.getLaunchViewController()
    }
}
