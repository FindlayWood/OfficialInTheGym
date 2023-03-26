//
//  PublicClipsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PublicClipsViewController: UIViewController, CustomAnimatingClipFromVC {
    // coordinator
    weak var coordinator: UserProfileCoordinator?
    // child vc
    var childVC = ClipsChildViewController()
    // view model
    var viewModel = PublicClipsViewModel()
    // subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Clip Animations
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?

    // MARK: - View
    override func loadView() {
        view = childVC.display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        childVC.didMove(toParent: self)
        childVC.display.searchField.delegate = self
    }
    // MARK: - Init Data Source
    func initDataSource() {
        childVC.dataSource.selectedCell
            .sink { [weak self] selectedCell in
                self?.selectedCell = selectedCell.selectedCell
                self?.selectedCellImageViewSnapshot = selectedCell.snapshot
            }
            .store(in: &subscriptions)
        childVC.dataSource.clipSelected
            .sink { [weak self] in self?.showClip($0)}
            .store(in: &subscriptions)
    }
    // MARK: - Init View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$clips
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.$clips
            .sink { [weak self] in self?.childVC.display.updateDisplay($0.isEmpty) }
            .store(in: &subscriptions)
        viewModel.fetchClipKeys()
        viewModel.initSubscribers()
    }
}
// MARK: - Actions
private extension PublicClipsViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    func showClip(_ clipModel: ClipModel) {
        coordinator?.clipSelected(clipModel, fromViewControllerDelegate: self)
    }
}
// MARK: - Search Bar Delegate
extension PublicClipsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
