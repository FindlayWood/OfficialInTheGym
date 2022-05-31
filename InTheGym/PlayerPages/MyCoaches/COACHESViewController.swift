//
//  COACHESViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class COACHESViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: PlayerProfileMoreCoordinator?
    var display = MyCoachesView()
    var viewModel = MyCoachesViewModel()
    var dataSource: UsersDataSource!
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
        display.tableview.backgroundColor = .secondarySystemBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.userSelected
            .sink { [weak self] in self?.coordinator?.userSelected($0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$coachModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.fetchCoachKeys()
    }
}
// MARK: - Actions
extension COACHESViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
