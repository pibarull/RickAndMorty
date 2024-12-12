//
//  CharacterViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit
import RxSwift

final class CharacterViewController: UIViewController {

    // Call when user tap on back arrow in navigation tab
    var dismiss: (() -> ())?
    private var tableView: UITableView
    private var headerView: CharacterHeaderView?
    private let viewModel: CharacterViewModel
    private var firstTimeAppearance: Bool = true
    private let disposeBag = DisposeBag()

    var openedCharacterDetails: ((CharacterFull) -> ())?

    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel

        tableView = UITableView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        setupRx()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)

        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "RMSmallicon"), style: .plain, target: self, action: nil)
        barButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = barButtonItem

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "arrowBackIcon"), for: .normal)//?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.setTitle("GO BACK", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backButton.tintColor = .black
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)

        backButton.addTarget(self, action: #selector(goBackTapped), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc func goBackTapped() {
        dismiss?()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.reuseIdentifier)
        tableView.dataSource = self

        let headerView = CharacterHeaderView(name: viewModel.character.name, image: viewModel.character.image.image)
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 300)
        self.headerView = headerView
        tableView.tableHeaderView = headerView
    }

    private func setupLayout() {
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(16)
        }
    }

    private func setupRx() {
        headerView?.cameraTapped
            .asObservable()
            .subscribe { [weak self] _ in
                guard let self else { return }

                print("Camera button pressed")
                //Open camera/gallery
            }
            .disposed(by: disposeBag)
    }
}

extension CharacterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : UITableView.automaticDimension
    }
}

extension CharacterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.reuseIdentifier, for: indexPath) as? CharacterCell,
              let image = viewModel.character.image.image else {
            return UITableViewCell(frame: .zero)
        }

        cell.selectionStyle = .none
        cell.configure(with: viewModel.cellData[indexPath.row], image: image)
        return cell
    }
}
