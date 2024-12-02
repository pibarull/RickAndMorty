//
//  EpisodesViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit
import RxSwift

enum Section {
    case main
}

final class EpisodesViewController: UIViewController {

    private var collectionView: UICollectionView
    private var loadingView = LoadingView()
    private var searchPicker = SearchPicker()
    private let viewModel: EpisodesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, EpisodeFull>!
    private var firstTimeAppearance: Bool = true
    private var selectedCategory: Category = .byEpisodeNumber
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
        updateCollection(with: viewModel.episodes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await viewModel.getEpisodes()
            firstTimeAppearance = false
        }

        setupUI()
        setupLayout()
        setupRx()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(collectionView)
        view.addSubview(loadingView)
        loadingView.isHidden = true
        loadingView.start()
        view.addSubview(searchPicker)
        searchPicker.backgroundColor = .gray
        searchPicker.isHidden = true

        setupCollectionView()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 300)
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
        collectionView.register(EpisodesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EpisodesHeaderView.reuseIdentifier)

        dataSource = UICollectionViewDiffableDataSource<Section, EpisodeFull>(collectionView: collectionView) { [weak self] (tableView, indexPath, episode) -> UICollectionViewCell? in
            guard let self else { return UICollectionViewCell() }

            let episodes = self.viewModel.episodes
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as? EpisodeCell,
                  !episodes.isEmpty else {
                return UICollectionViewCell()
            }

            cell.configure(with: episodes[indexPath.row])
            return cell
        }
        setupHeader()
    }

    func setupHeader() {
        var textFieldSubscription: Disposable?
        var selectorSubscription: Disposable?

        dataSource?.supplementaryViewProvider = { [weak self] (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in
            let header: EpisodesHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: EpisodesHeaderView.reuseIdentifier,
                for: indexPath) as! EpisodesHeaderView

            if textFieldSubscription != nil || selectorSubscription != nil {
                textFieldSubscription?.dispose()
                selectorSubscription?.dispose()
            }

            textFieldSubscription = header.searchEpisodeTextField.rx.controlEvent(.editingChanged)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self,
                          let searchQuery = header.searchEpisodeTextField.text else { return }

                    self.searchEpisodes(by: searchQuery)
                })

            selectorSubscription = header.selectCategoryButton.rx.tap
                .bind { [weak self] _ in
                    guard let self else { return }
                    
                    searchPicker.isHidden = !searchPicker.isHidden
                }

            if let textFieldSubscription = textFieldSubscription,
               let selectorSubscription = selectorSubscription {
                self?.disposeBag.insert(textFieldSubscription)
                self?.disposeBag.insert(selectorSubscription)
            }

            return header
        }
    }

    private func setupLayout() {
        loadingView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        searchPicker.snp.makeConstraints { maker in
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalTo(200)
        }

        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(16)
        }
    }

    private func setupRx() {
        viewModel.state.asObservable()
            .subscribe { [weak self] state in
                self?.updateUI(with: state)
            }
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .bind { [weak self] in
                guard let self else { return }

                self.loadingView.start()
            }
            .disposed(by: disposeBag)

        EpisodeCell.addedToFavourites
            .subscribe { [weak self] shouldBeAdded, episodeId in
                guard let self = self else { return }
                if shouldBeAdded {
                    viewModel.addFavourite(episodeId: episodeId)
                } else {
                    viewModel.removeFavourite(episodeId: episodeId)
                }
                updateCollection(with: viewModel.episodes)
            }
            .disposed(by: disposeBag)

        searchPicker.selectedCategory
            .asObserver()
            .subscribe { [weak self] category in
                guard let self else { return }

                selectedCategory = category.element ?? .byEpisodeNumber
                searchPicker.isHidden = !searchPicker.isHidden

                if let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? EpisodesHeaderView {
                    searchEpisodes(by: header.searchEpisodeTextField.text ?? "")
                }
            }
            .disposed(by: disposeBag)
    }

    private func searchEpisodes(by searchQuery: String) {
        Task {
            switch self.selectedCategory {
            case .byEpisodeNumber:
                await self.viewModel.getEpisodes(byEpisode: searchQuery)
            case .byName:
                await self.viewModel.getEpisodes(byName: searchQuery)
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.updateCollection(with: self.viewModel.episodes)
            }
        }
    }

    private func updateUI(with state: EpisodesViewModel.State) {
        switch state {
        case .loading:
            loadingView.start()
            tabBarController?.tabBar.isUserInteractionEnabled = false
            collectionView.isUserInteractionEnabled = false
            loadingView.isHidden = false
        case .loaded:
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                loadingView.stop()
                loadingView.isHidden = true
                tabBarController?.tabBar.isUserInteractionEnabled = true
                collectionView.isUserInteractionEnabled = true
                updateCollection(with: viewModel.episodes)
            }
        case .error(let error):
            //Show error alert
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                loadingView.stop()
                loadingView.isHidden = true
                updateCollection(with: viewModel.episodes)
            }
        }
    }

    private func configureCollection(with episodes: [EpisodeFull]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeFull>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.episodes)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateCollection(with episodes: [EpisodeFull]) {
//        if episodes.isEmpty -> show no results view for Favourites screen

        if firstTimeAppearance {
            var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeFull>()
            snapshot.appendSections([.main])
            snapshot.appendItems(viewModel.episodes)
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
            if let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? EpisodesHeaderView {
                header.searchEpisodeTextField.becomeFirstResponder()
            }
        }
    }
}

extension EpisodesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCharacter = viewModel.episodes[indexPath.row].selectedCharacter else { return }

        print("Selected character: \(selectedCharacter.name)")
        openedCharacterDetails?(selectedCharacter)
    }
}
