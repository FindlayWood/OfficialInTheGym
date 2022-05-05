//
//  CreateNewGroupViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine

class CreateNewGroupViewController: UIViewController {
    
    weak var coordinator: GroupCoordinator?
    
//    var delegate: MyGroupsProtocol!
    var dataSource: UsersDataSource!
    
    var display = CreateNewGroupView()
    
    var viewModel = CreateNewGroupViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Create New Group"
        initDataSource()
        initViewModel()
        initDisplay()
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
    }
    
    func initDisplay() {
        display.groupNameField.delegate = self
        display.addPlayersButton.addTarget(self, action: #selector(addPlayers(_:)), for: .touchUpInside)
    
        display.groupNameField.textPublisher
            .sink { [weak self] in self?.viewModel.groupTitle = $0 }
            .store(in: &subscriptions)
        
//        display.groupNameField.publisher(for: \.text)
//            .compactMap {$0}
//            .sink { [weak self] in self?.viewModel.groupTitle = $0}
//            .store(in: &subscriptions)
    }

    func initViewModel() {
        viewModel.$selectedUsers
            .compactMap {$0}
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$canCreate
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        
    }
    
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
    }
    
    @objc func createGroup() {
        viewModel.createNewGroup()
    }
}
// MARK: - Actions
private extension CreateNewGroupViewController {
    @objc func addPlayers(_ sender: UIButton) {
        let vc = UserSelectionViewController()
        vc.viewModel.currentlySelectedUsers = Set(viewModel.selectedUsers)
        viewModel.observeSelection(vc.viewModel.selectedUsers)
        present(vc, animated: true)
    }
}
