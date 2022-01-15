//
//  SavedWorkoutsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SavedWorkoutsDataSource: NSObject {
    // MARK: - Publisher
    var workoutSelected = PassthroughSubject<IndexPath,Never>()
    // MARK: - Properties
    var tableView: UITableView
    private lazy var dataDource = makeDataSource()
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<Int,SavedWorkoutModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedWorkoutTableViewCell.cellID, for: indexPath) as! SavedWorkoutTableViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,SavedWorkoutModel>()
        snapshot.appendSections([1])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [SavedWorkoutModel]) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(models, toSection: 1)
        dataDource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension SavedWorkoutsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutSelected.send(indexPath)
    }
}
