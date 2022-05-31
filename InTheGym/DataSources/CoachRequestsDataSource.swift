//
//  CoachRequestsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//


import Foundation
import UIKit
import Combine

class CoachRequestsDataSource: NSObject {
    
    // MARK: - Publosher
    var userSelected = PassthroughSubject<Users,Never>()
    
    var requestSent = PassthroughSubject<IndexPath,Never>()
    
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
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,CoachRequestCellModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: CoachRequestTableViewCell.cellID, for: indexPath) as! CoachRequestTableViewCell
            cell.configure(with: itemIdentifier)
            cell.sendRequestAction
                .sink { [weak self] in self?.action(indexPath)}
                .store(in: &self.subscriptions)
            return cell
        }
    }
    // MARK: - Update
    func updateTable(with users: [CoachRequestCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,CoachRequestCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Action
    func action(_ indexPath: IndexPath) {
        requestSent.send(indexPath)
    }
}
// MARK: - Delegate
extension CoachRequestsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        userSelected.send(model.user)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
}
