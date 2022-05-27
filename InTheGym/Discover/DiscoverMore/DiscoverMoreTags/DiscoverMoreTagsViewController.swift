//
//  DiscoverMoreTagsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverMoreTagsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: SearchTagCoordinator?
    
    var display = DiscoverMoreTagsView()
    
    var viewModel = DiscoverMoreTagsViewModel()
    
    var dataSource: SearchTagsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDataSource()
        initViewModel()
        display.searchField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.itemSelected
            .sink { [weak self] in self?.itemSelected($0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setNavBar($0)}
            .store(in: &subscriptions)
        viewModel.$cellModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension DiscoverMoreTagsViewController {
    func itemSelected(_ model: TagAndExerciseCellModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: model.exercise)
        coordinator?.exerciseSelected(discoverModel)
    }
}
// MARK: - Search Bar Delegate
extension DiscoverMoreTagsViewController: UISearchBarDelegate {
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
// MARK: - Loading Nav Bar
private extension DiscoverMoreTagsViewController {
    func setNavBar(_ searching: Bool) {
        if searching {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
