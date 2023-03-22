//
//  AddPlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddPlayerViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: AddPlayerCoordinator?
    
    var childContentView: SearchPlayerView!
    var viewModel = AddPlayerViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initNavBar()
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
    }
    func addChildView() {
        childContentView = .init(viewModel: viewModel){ [weak self] cellModel in
            self?.coordinator?.showUser(cellModel.user)
        }
        addSwiftUIViewWithNavBar(childContentView)
    }
    // MARK: - Nav Bar
    func initNavBar() {
        let dismissButton = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(dismissAction))
        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.title = "Add Players"
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$loadingRequests
            .sink { [weak self] in self?.setInitialLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
        viewModel.loadCurrentRequests()
    }
}
//MARK: - Actions
private extension AddPlayerViewController {
    func setLoading(_ loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    func setInitialLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    @objc func dismissAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
