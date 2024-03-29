//
//  DiscoverMoreWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverMoreWorkoutsViewController: UIViewController {
    
    weak var coordinator: DiscoverCoordinator?
    
    var childVC = SavedWorkoutsChildViewController()
    
    var viewModel = DiscoverMoreWorkoutsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = childVC.display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initViewModel()
        initDataSource()
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
        
        childVC.dataSource.workoutSelected
            .sink { [weak self] in self?.coordinator?.workoutSelected($0)}
            .store(in: &subscriptions)
    }
    // MARK: - Init View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$workouts
            .sink { [weak self] in self?.childVC.dataSource.updateCollection(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadWorkouts()
        viewModel.initSubscribers()
    }
}
// MARK: - Actions
private extension DiscoverMoreWorkoutsViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
// MARK: - Search Bar Delegate
extension DiscoverMoreWorkoutsViewController: UISearchBarDelegate {
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
