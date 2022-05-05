//
//  UserSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class UserSelectionViewController: UIViewController {
    
    // - View Model
    var viewModel = UserSelectionViewModel()
    
    // - Data Source
    var dataSource: UserSelectionDataSource!
    
    // - Subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    // - Done Button
    var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // - Cancel Button
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // - Tableview
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initDataSource()
        initViewModel()
        doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Init Data Source
    func initDataSource() {
        dataSource = .init(tableView: tableview)
        
        dataSource.userSelected
            .sink { [weak self] in self?.viewModel.addUser($0)}
            .store(in: &subscriptions)
        
        dataSource.userDeSelected
            .sink { [weak self] in self?.viewModel.removeUser($0)}
            .store(in: &subscriptions)
        
    }
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.$allUsers
            .compactMap { $0 }
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.loadUsers()
    }
}
// MARK: - Actions
private extension UserSelectionViewController {
    @objc func donePressed(_ sender: UIButton) {
        viewModel.done()
        dismiss(animated: true)
    }
}

// MARK: - Setup UI
private extension UserSelectionViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(tableview)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableview.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 16),
            tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
