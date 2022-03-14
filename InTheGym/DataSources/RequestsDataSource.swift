//
//  RequestsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class RequestsDataSource: NSObject {
    
    // MARK: - Publosher
    var userSelected = PassthroughSubject<Users,Never>()
    
    var acceptSelected = PassthroughSubject<RequestCellModel,Never>()
    
    var declineSelected = PassthroughSubject<RequestCellModel,Never>()
    
    var errorPublisher = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,RequestCellModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: RequestTableViewCell.cellID, for: indexPath) as! RequestTableViewCell
            cell.viewModel.cellModel = itemIdentifier
            cell.configure(with: itemIdentifier)
            cell.actionPublisher
                .sink { [weak self] in self?.action($0)}
                .store(in: &self.subscriptions)
//            self.subscriptions[indexPath] = cell.actionPublisher
//                .sink { [weak self] action in
//                    self?.action(action)
//                }
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,RequestCellModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with users: [RequestCellModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(users, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Remove
    func remove(_ model: RequestCellModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems([model])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Action
    func action(_ action: RequestCellAction) {
        switch action {
        case .accept(let cellModel):
            acceptSelected.send(cellModel)
            remove(cellModel)
        case .decline(let cellModel):
            declineSelected.send(cellModel)
            remove(cellModel)
        case .error:
            errorPublisher.send(())
        }
    }
}

// MARK: - Delegate
extension RequestsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let user = dataSource.itemIdentifier(for: indexPath) else {return}
//        userSelected.send(user)
    }
}
