//
//  CharacterCell.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 10.12.2024.
//

import Foundation
import UIKit

final class CharacterCell: UITableViewCell {

    static let reuseIdentifier = "CharacterCell"

    private let containerView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with data: CharacterViewModel.CellData) {
        titleLabel.text = data.0
        subtitleLabel.text = data.1
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(4)
            maker.right.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
        }

        subtitleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(4)
            maker.right.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
        }
    }
}
