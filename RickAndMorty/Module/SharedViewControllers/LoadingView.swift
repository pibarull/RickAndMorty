//
//  LoadingView.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 19.11.2024.
//

import Foundation
import UIKit

final class LoadingView: UIView {

    private let loadingIcon: UIImageView = {
        let image = UIImage(named: "LaunchLoading")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.opacity = 0.3
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupUI()
//        setupLayout()
//    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(backgroundView)
        addSubview(loadingIcon)
    }

    private func setupLayout() {
        loadingIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func start() {
        loadingIcon.rotate()
    }

    func stop() {
        loadingIcon.stopRotation()
    }
}
