//
//  EpisodesHeaderView.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 26.11.2024.
//

import Foundation
import UIKit

final class EpisodesHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "EpisodesHeaderView"

    private let launchIcon: UIImageView = {
        let image = UIImage(named: "LaunchIcon")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    let searchEpisodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name of episode (ex. S10E01)..."
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        let imageView = UIImageView(image: UIImage(named: "searchIcon"))
        imageView.contentMode = .scaleAspectFit

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        imageView.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        containerView.addSubview(imageView)

        textField.leftViewMode = .always
        textField.leftView = containerView
        
        return textField
    }()

    let selectCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("ADVANCED FILTERS", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor(hex: "#2196F3"), for: .normal)
        let image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        

        button.setImage(image, for: .normal)
        button.tintColor = .gray

        button.backgroundColor = UIColor(hex: "#E3F2FD")
        button.layer.cornerRadius = 8

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.7

        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -65, bottom: 0, right: 65)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(launchIcon)
        addSubview(searchEpisodeTextField)
        addSubview(selectCategoryButton)
    }

    private func setupLayout() {
        launchIcon.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview().inset(16)
            maker.height.equalTo(104)
        }

        searchEpisodeTextField.snp.makeConstraints { maker in
            maker.top.equalTo(launchIcon.snp.bottom).offset(40)
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().inset(16)
            maker.height.equalTo(56)
        }

        selectCategoryButton.snp.makeConstraints { maker in
            maker.top.equalTo(searchEpisodeTextField.snp.bottom).offset(10)
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().inset(16)
            maker.height.equalTo(56)
            maker.bottom.equalToSuperview().inset(30)
        }
    }
}
