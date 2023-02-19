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
    var childContentView: FollowersFollowingView!
    // view model
    var viewModel = MyFollowersViewModel()
    // subscriptions
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    func addChildView() {
        childContentView = .init(viewModel: viewModel) { [weak self] selectedUser in
            self?.coordinator?.showUser(user: selectedUser)
        }
        addSwiftUIViewWithNavBar(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$navigationTitle
            .sink { [weak self] in self?.navigationItem.title = $0}
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
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
