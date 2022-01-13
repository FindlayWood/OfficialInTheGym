//
//  UsersListViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

// MARK: - UsersListViewController
/// This viewcontroller is used to display a list of users in a tableview
/// It will only ever be used as a childVC


import UIKit
import Combine

class UsersListViewController: UITableViewController {
    
    // MARK: - Properties
    var usersToDisplay: [Users]!
    
    // MARK: - Data Source
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Publishers
    var selectedUser = PassthroughSubject<Users,Never>()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        tableView.dataSource = makeDataSource()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser.send(usersToDisplay[indexPath.row])
    }
}

// MARK: - Diffable Data Source
extension UsersListViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int,Users> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
            cell.configureCell(with: itemIdentifier)
            return cell
        }
    }
    func initialTableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([1])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updateTable(with users: [Users]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(users, toSection: 1)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
