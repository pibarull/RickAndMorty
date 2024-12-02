//
//  TabBarController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {

    weak var coordinator: TabBarCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
    }

    private func setupUI() {
        tabBar.backgroundColor = .white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height : -3.0)
        tabBar.layer.shadowOpacity = 0.3
    }

    private func layout() {

    }
}
