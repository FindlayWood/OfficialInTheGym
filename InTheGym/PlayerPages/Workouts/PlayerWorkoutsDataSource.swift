//
//  PlayerWorkoutsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PlayerWorkoutsDataSource: NSObject {
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
    func makeDataSource() -> UITableViewDiffableDataSource<Int,WorkoutModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.cellID, for: indexPath) as! WorkoutTableViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,WorkoutModel>()
        snapshot.appendSections([1])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [WorkoutModel]) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(models, toSection: 1)
        dataDource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension PlayerWorkoutsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutSelected.send(indexPath)
    }
}
