//
//  MyWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyWorkoutsViewController: UIViewController {
    // coordinator
    weak var coordinator: MyProfileCoordinator?
    // view model
    var viewModel = MyWorkoutsViewModel()
    // child vc
    var childVC = SavedWorkoutsChildViewController()
    // subscriptions
    private var subscriptions = Set<AnyCancellable>()

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
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
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
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0)}
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
        viewModel.fetchWorkoutKeys()
        viewModel.initSubscribers()
    }
}
// MARK: - Actions
private extension MyWorkoutsViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
// MARK: - Search Bar Delegate
extension MyWorkoutsViewController: UISearchBarDelegate {
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
