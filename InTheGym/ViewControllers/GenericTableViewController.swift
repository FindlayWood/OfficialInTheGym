//
//  GenericTableViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

// MARK: - Generic Table View Doesnt quite work

import UIKit
import Combine

class GenericTableViewController<Model:Hashable>: UITableViewController {
    // MARK: - Properties
    var modelsToDisplay: [Model]!
    
    // MARK: - Data Source
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Publishers
    var selectedModel = PassthroughSubject<Model,Never>()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.cellID)
        tableView.dataSource = makeDataSource()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedModel.send(modelsToDisplay[indexPath.row])
    }
}

// MARK: - Diffable Data Source
extension GenericTableViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int,Model> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = UITableViewCell()
            return cell
        }
    }
    func initialTableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([1])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updateTable(with models: [Model]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: 1)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
