//
//  CreateNewGroupViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class CreateNewGroupViewController: UIViewController {
    
    weak var coordinator: GroupCoordinator?
    
    var delegate: MyGroupsProtocol!
    
    var display = CreateNewGroupView()
    
    var adapter: CreateNewGroupAdapter!
    
    let apiService = FirebaseAPIGroupService.shared
    
    lazy var viewModel: CreateNewGroupViewModel = {
        return CreateNewGroupViewModel(apiService: apiService)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.offWhiteColour
        navigationItem.title = "Create New Group"
        initDisplay()
        initViewModel()
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
    }

    func initViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.tableview.reloadData()
            }
        }
        viewModel.successfullCreationClosure = { [weak self] in
            guard let self = self else {return}
            self.showSuccess()
        }
        viewModel.errorCreationClosure = { [weak self] in
            guard let self = self else {return}
            self.showError()
        }
    }
    
    @objc func createGroup() {
        viewModel.createNewGroup()
    }
}

// MARK: - Display Configuration
extension CreateNewGroupViewController {
    func initDisplay() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = Constants.offWhiteColour
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
        coordinator?.addPlayersToNewGroup(self, selectedPlayers: viewModel.addedPlayers)

    }
}

extension CreateNewGroupViewController: AddedPlayersProtocol {
    func newPlayersAdded(_ players: [Users]) {
        viewModel.addNewPlayers(players)
        if players.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            textFieldDidEndEditing(display.groupNameField)
        }
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

// MARK: - Alert Methods
extension CreateNewGroupViewController {
    func showSuccess() {
        let alert = SCLAlertView()
        alert.showSuccess("New Group", subTitle: "You created a new group, \(display.groupNameField.text ?? "group"), you can now set workouts for this group specifically.", closeButtonTitle: "Ok")
        display.groupNameField.text = ""
        textFieldDidEndEditing(display.groupNameField)
        viewModel.addedPlayers.removeAll()
        delegate.addedNewGroup()
        navigationController?.popViewController(animated: true)
    }
    func showError() {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "There was an error trying to create your new group. Please try again shortly.", closeButtonTitle: "Ok")
    }
}
