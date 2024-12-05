//
//  FavouritesViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit
import RxSwift

final class FavouritesViewController: UIViewController {

    private var collectionView: UICollectionView
    private let viewModel: EpisodesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, EpisodeFull>!
    private var firstTimeAppearance: Bool = true
    private let disposeBag = DisposeBag()

    var openedCharacterDetails: ((CharacterFull) -> ())?

    init(viewModel: EpisodesViewModel) {
        self.viewModel = viewModel

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.getFavouriteEpisodes()
        updateCollection(with: viewModel.favouriteEpisodes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.updateCollection(with: self.viewModel.favouriteEpisodes)
            firstTimeAppearance = false
        }

        setupUI()
        setupLayout()
        setupRx()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)

        setupCollectionView()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 40, right: 0)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 40
            layout.itemSize = CGSize(width: self.view.frame.size.width - 52, height: 360)
            layout.invalidateLayout()
        }

        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(EpisodeCell.self, forCellWithReuseIdentifier: EpisodeCell.reuseIdentifier)

        dataSource = UICollectionViewDiffableDataSource<Section, EpisodeFull>(collectionView: collectionView) { [weak self] (tableView, indexPath, episode) -> UICollectionViewCell? in
            guard let self else { return UICollectionViewCell() }

            let episodes = self.viewModel.favouriteEpisodes
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as? EpisodeCell,
                  !episodes.isEmpty else {
                return UICollectionViewCell()
            }

            cell.configure(with: episodes[indexPath.row])
            return cell
        }
        collectionView.dataSource = dataSource
    }

    private func setupLayout() {
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(16)
        }
    }

    private func setupRx() {
        EpisodeCell.addedToFavourites
            .subscribe { [weak self] shouldBeAdded, episodeId in
                guard let self = self else { return }
                if shouldBeAdded {
                    viewModel.addFavourite(episodeId: episodeId)
                } else {
                    viewModel.removeFavourite(episodeId: episodeId)
                    viewModel.getFavouriteEpisodes()
                }
                updateCollection(with: viewModel.favouriteEpisodes)
            }
            .disposed(by: disposeBag)
    }

    private func configureCollection(with episodes: [EpisodeFull]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeFull>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.favouriteEpisodes)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateCollection(with episodes: [EpisodeFull]) {
//        if episodes.isEmpty -> show no results view for Favourites screen

        if firstTimeAppearance {
            var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeFull>()
            snapshot.appendSections([.main])
            snapshot.appendItems(viewModel.favouriteEpisodes)
            dataSource.apply(snapshot, animatingDifferences: false)
        } else {
            var snapShot = dataSource.snapshot()
            let diff = episodes.difference(from: snapShot.itemIdentifiers)
            let currentIdentifiers = snapShot.itemIdentifiers
            guard let newIdentifiers = currentIdentifiers.applying(diff) else {
                return
            }
            snapShot.deleteItems(currentIdentifiers)
            snapShot.appendItems(newIdentifiers)
            dataSource.apply(snapShot, animatingDifferences: false)
            collectionView.reloadData()
        }
    }
}

extension FavouritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCharacter = viewModel.favouriteEpisodes[indexPath.row].selectedCharacter else { return }

        print("Selected character: \(selectedCharacter.name)")
        openedCharacterDetails?(selectedCharacter)
    }
}
