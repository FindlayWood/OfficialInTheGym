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
    
    var adapter: CreateNewGroupAdapter!
    
    let apiService = FirebaseAPIGroupService.shared
    
    lazy var viewModel: CreateNewGroupViewModel = {
        return CreateNewGroupViewModel(apiService: apiService)
    }()
    
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

    func initViewModel() {
        viewModel.$selectedUsers
            .compactMap {$0}
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
    }
    
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
    }
    
    @objc func createGroup() {
        viewModel.createNewGroup()
    }
}

// MARK: - Display Configuration
extension CreateNewGroupViewController {
    func initDisplay() {
        display.groupNameField.delegate = self
        display.addPlayersButton.addTarget(self, action: #selector(addPlayers(_:)), for: .touchUpInside)
    }
}

// MARK: - Textfield Delegate
extension CreateNewGroupViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let empty = textField.text?.isEmpty {
            if !empty && viewModel.numberOfItems > 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == display.groupNameField {
            viewModel.updateGroupTitle(with: newString)
        }
        return true
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
