//
//  DescriptionsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class DescriptionsDataSource: NSObject {
    // MARK: - Publisher
    var exerciseSelected = PassthroughSubject<DescriptionModel,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,DescriptionModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.cellID, for: indexPath) as! DescriptionTableViewCell
            cell.configure(with: itemIdentifier)
            self.actionSubscriptions[indexPath] = cell.actionPublisher
                .sink(receiveValue: { [weak self] action in
                    switch action {
                    case .upVote, .downVote:
                        self?.reloadRow(with: itemIdentifier)
                    case .userTapped:
                        print("user tapped!!!")
                    }
                })
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,DescriptionModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [DescriptionModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,DescriptionModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Reload Row
    func reloadRow(with model: DescriptionModel) {
//        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadItems([model])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension DescriptionsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        exerciseSelected.send(model)
    }
}
