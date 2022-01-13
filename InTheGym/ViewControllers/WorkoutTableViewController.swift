//
//  WorkoutTableViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

// MARK: - WorkoutsListViewController
/// This viewcontroller is used to display a list of saved workouts in a tableview
/// It will only ever be used as a childVC


import UIKit
import Combine

class WorkoutTableViewController: UITableViewController {
    
    // MARK: - Properties
    var workoutsToDisplay: [SavedWorkoutModel]!
    
    // MARK: - Data Source
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Publishers
    var selectedWorkout = PassthroughSubject<SavedWorkoutModel,Never>()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.cellID)
        tableView.dataSource = makeDataSource()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWorkout.send(workoutsToDisplay[indexPath.row])
    }
}

// MARK: - Diffable Data Source
extension WorkoutTableViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int,SavedWorkoutModel> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.cellID, for: indexPath) as! WorkoutTableViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    func initialTableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([1])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updateTable(with workouts: [SavedWorkoutModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(workouts, toSection: 1)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

