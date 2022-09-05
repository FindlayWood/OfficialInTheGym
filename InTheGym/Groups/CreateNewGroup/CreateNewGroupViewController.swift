//
//  CreateNewGroupViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
//import SCLAlertView
import Combine

class CreateNewGroupViewController: UIViewController {
    
    weak var coordinator: GroupCoordinator?
    
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
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Init Display
    func initDisplay() {
        display.addPlayersButton.addTarget(self, action: #selector(addPlayers(_:)), for: .touchUpInside)
        display.groupNameField.textPublisher
            .sink { [weak self] in self?.viewModel.groupTitle = $0 }
            .store(in: &subscriptions)
    }
    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initLoadingNavBar() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.startAnimating()
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButton
    }

    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.newUsersSelected
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$canCreate
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.createdNewGroup?
            .sink { [weak self] newGroup in
                self?.coordinator?.goToGroupHome(newGroup)
                self?.display.groupNameField.text = ""
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setToLoading($0)}
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
        coordinator?.addUsers(viewModel.newUsersSelected.value, listener: viewModel.newUsersSelected)
    }
    func setToLoading(_ value: Bool) {
        navigationItem.hidesBackButton = value
        display.groupNameField.resignFirstResponder()
        if value {
            initLoadingNavBar()
        } else {
            initNavBar()
        }
    }
}
