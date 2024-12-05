//
//  EpisodeCell.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 22.11.2024.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxGesture

final class EpisodeCell: UICollectionViewCell {

    static let reuseIdentifier = "EpisodeCell"
    // Should I use???
    static let addedToFavourites = PublishSubject<(Bool, Int)>()

    private let containerView = UIView()
    private let clippingView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let footerView = UIView()

    private let footerImage: UIImageView = {
        let image = UIImage(named: "playIcon")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let footerTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 2
        return label
    }()

    private let favouriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "favouritesIcon"), for: .normal)
        button.setImage(UIImage(named: "favouriteFilledIcon"), for: .selected)
        return button
    }()

    private let disposeBag = DisposeBag()
    private var episode: EpisodeFull?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        setupRx()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with episode: EpisodeFull) {
        if episode.id == -404 {
            titleLabel.text = "Error: Unable to fetch data"
            imageView.image = nil
            footerTitle.text = "Please try a new query"
        } else {
            titleLabel.text = episode.selectedCharacter?.name
            imageView.image = episode.selectedCharacter?.image
            footerTitle.text = "\(episode.name) | \(episode.episode)"
            favouriteButton.isSelected = episode.isFavourite
            self.episode = episode
        }
    }

    func startLoading() {
        titleLabel.text = nil
        imageView.image = UIImage(named: "LaunchLoading")
        footerTitle.text = nil
        imageView.rotate()
    }

    private func setupUI() {
        backgroundColor = .white

        containerView.backgroundColor = UIColor.clear
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = .zero

        clippingView.layer.cornerRadius = 10
        clippingView.backgroundColor = .white
        clippingView.layer.masksToBounds = true

        contentView.addSubview(containerView)
        containerView.addSubview(clippingView)
        clippingView.addSubview(imageView)
        clippingView.addSubview(titleLabel)
        clippingView.addSubview(footerView)
        footerView.addSubview(footerImage)
        footerView.addSubview(footerTitle)
        footerView.addSubview(favouriteButton)

        footerView.backgroundColor = .lightGray
        footerView.layer.opacity = 0.7
        footerView.layer.cornerRadius = 10
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        clippingView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(titleLabel.snp.top)
            maker.height.equalTo(312)
            maker.width.equalTo(232)
        }

        titleLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(imageView.snp.bottom).offset(10)
            maker.height.equalTo(54)
        }

        footerView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(titleLabel.snp.bottom)
            maker.height.equalTo(72)
        }

        footerImage.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(24)
            maker.right.equalTo(footerTitle.snp.left).offset(-10)
            maker.top.equalToSuperview().inset(20)
            maker.height.equalTo(32)
            maker.width.equalTo(34)
        }

        footerTitle.snp.makeConstraints { maker in
            maker.right.equalTo(favouriteButton.snp.left).inset(-10)
            maker.centerY.equalTo(footerImage)
        }

        favouriteButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().inset(24)
            maker.centerY.equalTo(footerImage)
            maker.height.width.equalTo(30)
        }
    }

    private func setupRx() {
        favouriteButton.rx.tap
            .bind { [weak self] in
                guard let self,
                let episode = self.episode else { return }
                
                UIView.animate(withDuration: 0.5) {
                    self.favouriteButton.isSelected = !episode.isFavourite
                }
                EpisodeCell.addedToFavourites.onNext((self.favouriteButton.isSelected, episode.id))
            }
            .disposed(by: disposeBag)
    }
}
