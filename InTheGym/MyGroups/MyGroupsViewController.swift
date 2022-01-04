//
//  MyGroupsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import EmptyDataSet_Swift

class MyGroupsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: GroupCoordinator?
    
    var display = MyGroupsView()
    
    private lazy var dataSource = makeDataSource()
    
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var tableview:UITableView!
    
    
    var adapter: MyGroupsAdapter!
    
    var viewModel = MyGroupViewModel()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        initUI()
        initDisplay()
        initialTableSetUp()
        //initViewModel()
        setupSubscribers()
//        initialTableSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            //initViewModel()
        }
        editNavBarColour(to: .darkColour)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            //viewModel.removeObservers()
        }
    }
    
    func initDisplay() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.separatorStyle = .none
    }
    
    func initUI(){
        self.navigationItem.title = "My Groups"
        if ViewController.admin {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGroup(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    // MARK: - Combine Subscribers
    func setupSubscribers() {
        viewModel.groups
            .dropFirst()
            .sink { [weak self] myGroups in
                guard let self = self else {return}
                self.updateGroups(with: myGroups)
                print("here are my groups...\(myGroups)")
            }
            .store(in: &subscriptions)
        
        viewModel.fetchReferences()
    }
    
    
    @IBAction func addNewGroup(_ sender:UIButton){
        coordinator?.addNewGroup(with: self)
    }
    


}

// MARK: - Tableview Datasource
extension MyGroupsViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<MyGroupSection,groupModel> {
        return UITableViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: MyGroupsTableViewCell.cellID, for: indexPath) as! MyGroupsTableViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    func initialTableSetUp() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.myGroups])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func updateGroups(with groups: [groupModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(groups, toSection: .myGroups)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
enum MyGroupSection {
    case myGroups
}

extension MyGroupsViewController: MyGroupsProtocol {
    
    func getGroup(at indexPath: IndexPath) -> groupModel {
        return viewModel.getGroup(at: indexPath)
    }
    
    func groupSelected(at indexPath: IndexPath) {
        // go to group page
        let selectedGroup = viewModel.getGroup(at: indexPath)
        coordinator?.goToGroupHome(selectedGroup)
    }
    
    func retreiveNumberOfGroups() -> Int {
        return viewModel.numberOfGroups
    }
    
    func addedNewGroup() {
        tableview.reloadData()
    }
    
    
}
