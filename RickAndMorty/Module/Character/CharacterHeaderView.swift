//
//  CharacterHeaderView.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 11.12.2024.
//

import Foundation
import UIKit
import RxCocoa
import RxRelay
import RxSwift

final class CharacterHeaderView: UIView {

    let cameraTapped = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let cameraButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cameraIcon")
        button.setImage(image, for: .normal)
        return button
    }()

    private let characterNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Information"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(name: String, image: UIImage?) {
        super.init(frame: .zero)
        characterNameLabel.text = name
        characterImageView.image = image
        setupUI()
        setupLayout()
        setupRx()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        addSubview(characterImageView)
        addSubview(cameraButton)
        addSubview(characterNameLabel)
        addSubview(infoLabel)
    }
    
    private func setupLayout() {
        characterImageView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(32)
            maker.size.equalTo(150)
            maker.centerX.equalToSuperview()
        }

        cameraButton.snp.makeConstraints { maker in
            maker.left.equalTo(characterImageView.snp.right).offset(4)
            maker.centerY.equalTo(characterImageView)
            maker.size.equalTo(32)
        }

        characterNameLabel.snp.makeConstraints { maker in
            maker.top.equalTo(characterImageView.snp.bottom).offset(32)
            maker.centerX.equalToSuperview()
        }

        infoLabel.snp.makeConstraints { maker in
            maker.top.equalTo(characterNameLabel.snp.bottom).offset(10)
            maker.right.equalToSuperview().inset(24)
            maker.bottom.equalToSuperview().inset(16)
            maker.left.equalToSuperview()
        }
    }

    private func setupRx() {
        cameraButton.rx.tap.bind { [weak self] _ in
            self?.cameraTapped.accept(())
        }
        .disposed(by: disposeBag)
    }
}
