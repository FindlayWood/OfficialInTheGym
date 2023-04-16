//
//  MyGroupsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyGroupsViewController: UIViewController {
    
    // - Publisher
    var selectedGroup = PassthroughSubject<GroupModel,Never>()
    
    // - Properties
    weak var coordinator: GroupCoordinator?
    
    // - Display
    var display = MyGroupsView()
    
    // - Data Source
    var dataSource: MyGroupsDataSource!
    
    // - Subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    // - View Model
    var viewModel = MyGroupViewModel()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initDataSource()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Nav Bar
    func initNavBar(){
        if UserDefaults.currentUser.accountType == .coach {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGroup(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.groupSelected
            .sink { [weak self] group in
                self?.selectedGroup.send(group)
                self?.coordinator?.goToGroupHome(group)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.groups
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.newGroupCreated
            .sink { [weak self] in self?.dataSource.addNewGroup($0)}
            .store(in: &subscriptions)
        
        viewModel.fetchReferences()
    }
}
// MARK: - Actions
private extension MyGroupsViewController {
    @objc func addNewGroup(_ sender: UIButton) {
        coordinator?.addNewGroup(listener: viewModel.newGroupCreated)
    }
}

