//
//  CharacterViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit

final class CharacterViewController: UIViewController {

    // Call when user tap on back arrow in navigation tab
    var dismiss: (() -> ())?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
//        navigationController.leftBarButtonItems?.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
    }

    private func setupUI() {
        view.backgroundColor = .green
    }

    private func layout() {
    }
}
