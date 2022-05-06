//
//  GroupMembersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class GroupMembersViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: GroupHomeCoordinator?
    
    var childVC = UsersChildViewController()
    
    var viewModel = GroupMembersViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
        initDataSource()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        
        childVC.dataSource.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0)}
            .store(in: &subscriptions)
        
        initViewModel()
    }
    
     // MARK: - View Model
    func initViewModel() {
        
        viewModel.membersPublisher
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchMembers()
    }

}
