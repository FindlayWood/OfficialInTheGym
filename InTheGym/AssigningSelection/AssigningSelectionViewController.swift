//
//  AssigningSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AssigningSelectionViewController: UIViewController {
    
    // MARK: - View Model
    var viewModel = AssigningSelectedionViewModel()
    
    // MARK: - SwiftUI View
    var childContentView: AssignSelectionView!
    
    // MARK: - Subscriptions
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initViewModel()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Assign"
    }
    // MARK: - Add SswiftUI Child
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(childContentView)
    }

    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Assign", style: .done, target: self, action: #selector(assignAction(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.selectedUsers.isEmpty
    }
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isUploading
            .sink { [weak self] in self?.setNavBar($0) }
            .store(in: &subscriptions)
        
        viewModel.$selectedUsers
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = !$0.isEmpty }
            .store(in: &subscriptions)
        
        viewModel.uploadedPublisher
            .sink { [weak self] _ in self?.assignCompleted() }
            .store(in: &subscriptions)
        
        viewModel.fetchPlayers()
    }
}
// MARK: - Actions
private extension AssigningSelectionViewController {
    @objc func assignAction(_ sender: UIBarButtonItem) {
        viewModel.assignAction()
    }
    func setNavBar(_ loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            initNavBar()
        }
    }
    func assignCompleted() {
        viewModel.selectedUsers.removeAll()
        displayTopMessage(with: "Assigned")
    }
}
