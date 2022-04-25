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
    
    // MARK: - Publisher
    var selectedGroup = PassthroughSubject<GroupModel,Never>()
    
    // MARK: - Properties
    weak var coordinator: GroupCoordinator?
    
    // MARK: - Display
    var display = MyGroupsView()
    
    var dataSource: MyGroupsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel = MyGroupViewModel()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initDisplay()
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }

    func initDisplay() {
        display.tableview.separatorStyle = .none
    }
    
    func initNavBar(){
        if UserDefaults.currentUser.admin {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGroup(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
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
        
        viewModel.fetchReferences()
    }
    
    
    @IBAction func addNewGroup(_ sender: UIButton){
//        coordinator?.addNewGroup(with: self)
    }
}


