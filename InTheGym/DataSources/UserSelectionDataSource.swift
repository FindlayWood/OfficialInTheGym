//
//  UserSelectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class UserSelectionDataSource: NSObject {
    
    // MARK: - Publosher
    var userSelected = PassthroughSubject<Users,Never>()
    var userDeSelected = PassthroughSubject<Users,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,UserSelectionCellModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
            cell.configureCell(with: itemIdentifier.user)
            cell.accessoryType = itemIdentifier.isSelected ? .checkmark : .none
            cell.backgroundColor = itemIdentifier.isSelected ? .secondarySystemBackground : .systemBackground
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,UserSelectionCellModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with users: [UserSelectionCellModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(users, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Add
    func addTable(_ user: UserSelectionCellModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([user], toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate
extension UserSelectionDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellModel = dataSource.itemIdentifier(for: indexPath) else {return}
        
        var newModel = cellModel
        
        if newModel.isSelected {
            userDeSelected.send(newModel.user)
            newModel.isSelected.toggle()
        } else {
            userSelected.send(newModel.user)
            newModel.isSelected.toggle()
        }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.insertItems([newModel], afterItem: cellModel)
        currentSnapshot.deleteItems([cellModel])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
