//
//  MyFollowersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyFollowersViewController: UIViewController {
    // coordinator
    weak var coordinator: MyProfileCoordinator?
    // display
    var display = MyFollowersView()
    // view model
    var viewModel = MyFollowersViewModel()
    // data source
    var dataSource: UsersDataSource!
    // subscriptions
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Init Display
    func initDisplay() {
        display.segment.selectedIndex
            .sink { [weak self] in self?.viewModel.setSegment(to: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - Init Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$navigationTitle
            .sink { [weak self] in self?.navigationItem.title = $0}
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$usersToShow
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.fetchFollowerKeys()
        viewModel.fetchFollowingKeys()
    }
}
// MARK: - Actions
private extension MyFollowersViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
