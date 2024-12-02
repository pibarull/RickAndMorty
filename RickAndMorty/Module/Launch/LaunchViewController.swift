//
//  LaunchViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 16.11.2024.
//

import UIKit
import SnapKit

final class LaunchViewController: UIViewController {

    private let launchIcon: UIImageView = {
        let image = UIImage(named: "LaunchIcon")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let loadingIcon: UIImageView = {
        let image = UIImage(named: "LaunchLoading")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    var didFinishAnimation: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
        playAnimation()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(launchIcon)
        view.addSubview(loadingIcon)
    }

    private func layout() {
        launchIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(loadingIcon.snp.top).inset(-100)
            make.width.equalTo(312)
            make.height.equalTo(104)
        }

        loadingIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
    }

    private func playAnimation() {
        loadingIcon.rotate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.loadingIcon.stopRotation()
            self?.didFinishAnimation?()
        }
    }
}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .infinity
        self.layer.add(rotation, forKey: "rotationAnimation")
    }

    func stopRotation() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
