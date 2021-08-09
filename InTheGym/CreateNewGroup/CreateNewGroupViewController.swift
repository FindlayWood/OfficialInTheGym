//
//  CreateNewGroupViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateNewGroupViewController: UIViewController {
    
    weak var coordinator: GroupCoordinator?
    
    var display = CreateNewGroupView()
    
    var adapter: CreateNewGroupAdapter!
    
    var viewModel: CreateNewGroupViewModel = {
        return CreateNewGroupViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
        view.addSubview(display)
    }

    func initViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.tableview.reloadData()
            }
        }
    }

}

// MARK: - Display Configuration
extension CreateNewGroupViewController {
    func initDisplay() {
        adapter = CreateNewGroupAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.groupNameField.delegate = self
    }
}

// MARK: - Protocol Methods
extension CreateNewGroupViewController: CreateNewGroupProtocol {
    func getData(at indexPath: IndexPath) -> Users {
        return viewModel.getData(at: indexPath)
    }
    func numberOfItems() -> Int {
        return viewModel.numberOfItems + 1
    }
    func addPlayers() {
        coordinator?.addPlayersToNewGroup()
    }
}

extension CreateNewGroupViewController: AddedPlayersProtocol {
    func newPlayersAdded(_ players: [Users]) {
        viewModel.addNewPlayers(players)
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
}

