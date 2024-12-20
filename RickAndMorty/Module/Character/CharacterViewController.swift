//
//  CharacterViewController.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 18.11.2024.
//

import UIKit
import SnapKit
import RxSwift
import AVFoundation
import Photos

final class CharacterViewController: UIViewController, UINavigationControllerDelegate {

    // Call when user tap on back arrow in navigation tab
    var dismiss: (() -> ())?
    var openedCharacterDetails: ((CharacterFull) -> ())?
    var imagePicker = UIImagePickerController()

    private var tableView: UITableView
    private var headerView: CharacterHeaderView?
    private let viewModel: CharacterViewModel
    private var firstTimeAppearance: Bool = true
    private let disposeBag = DisposeBag()

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
        imagePicker.delegate = self

        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "RMSmallicon"), style: .plain, target: self, action: nil)
        barButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = barButtonItem

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "arrowBackIcon"), for: .normal)
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

                let actionSheet = UIAlertController(title: "Загрузите изображение", message: nil, preferredStyle: .actionSheet)
                let cameraAction = UIAlertAction(title: "Камера", style: .default) { [weak self] _ in
                    // Can be moved to a separate manager class like `CameraManager`
                    self?.checkCameraAccess()
                }
                let galleryAction = UIAlertAction(title: "Галерея", style: .default) { [weak self] _ in
                    self?.checkPhotoLibraryAccess()
                }

                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

                actionSheet.addAction(cameraAction)
                actionSheet.addAction(galleryAction)
                actionSheet.addAction(cancelAction)
                self.present(actionSheet, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    private func checkCameraAccess() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.openCamera()
                } else {
                    // Dismiss the alert
                }
            }
        case .authorized:
            openCamera()
        case .denied, .restricted:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        @unknown default:
            print("Unknown camera authorization status")
        }
    }

    private func checkPhotoLibraryAccess() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            // Request access if not determined
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.openGallery()
                } else {
                    // Dismiss the alert
                }
            }
        case .restricted, .denied:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        case .authorized, .limited:
            openGallery()
        @unknown default:
            print("Unknown Photo Library authorization status")
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.reuseIdentifier, for: indexPath) as? CharacterCell else {
            return UITableViewCell(frame: .zero)
        }

        cell.selectionStyle = .none
        cell.configure(with: viewModel.cellData[indexPath.row])
        return cell
    }
}

extension CharacterViewController: UIImagePickerControllerDelegate {

    func openGallery() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            present(imagePicker, animated: true)
        }
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                imagePicker.allowsEditing = false
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true)
            }
        } else {
            print("Error!!@!@!@")
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let imageData = image.data else { return }

        viewModel.updateCharacterPhoto(with: imageData)
        headerView?.updateImage(with: image)
        dismiss(animated: true)
    }
}
