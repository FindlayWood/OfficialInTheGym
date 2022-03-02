//
//  GroupHomePageDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GroupHomePageDataSource: NSObject {
    
    // MARK: - Publisher
    var likeButtonTapped = PassthroughSubject<GroupPost,Never>()
    var workoutTapped = PassthroughSubject<GroupPost,Never>()
    var userTapped = PassthroughSubject<GroupPost,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
//        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source    
    func makeDataSource() -> UITableViewDiffableDataSource<GroupSections,GroupItems> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .name(let model):
                let cell = UITableViewCell()
                cell.textLabel?.text = model.username
                cell.textLabel?.font = Constants.font
                cell.selectionStyle = .none
                return cell
            case .leader(let leader):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
                cell.configureCell(with: leader)
                return cell
            case .info(let leaderID):
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupHomePageInfoTableViewCell.cellID, for: indexPath) as! GroupHomePageInfoTableViewCell
                cell.configureForLeader(leaderID)
//                cell.delegate = self
                return cell
            case .posts(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: model)
//                cell.delegate = self
                self.actionSubscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<GroupSections,GroupItems>()
        snapshot.appendSections([.groupName, .groupLeader, .groupInfo, .groupPosts])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Update
    func tableUpdate(with items: [GroupItems]) {
        var currentSnapshot = dataSource.snapshot()
        for item in items {
            switch item {
            case .name(let groupModel):
                currentSnapshot.appendItems([.name(groupModel)], toSection: .groupName)
            case .leader(let users):
                currentSnapshot.appendItems([.leader(users)], toSection: .groupLeader)
            case .info(let groupInfo):
                currentSnapshot.appendItems([.info(groupInfo)], toSection: .groupInfo)
            case .posts(let post):
                currentSnapshot.appendItems([.posts(post)], toSection: .groupPosts)
            }
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update Leader
    func updateLeader(_ leader: Users) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([GroupItems.leader(leader)], toSection: .groupLeader)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update Posts
    func tableUpdatePosts(with posts: [GroupPost]) {
        var currentSnapshot = dataSource.snapshot()
        for post in posts {
            currentSnapshot.appendItems([.posts(post)], toSection: .groupPosts)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Actions
    func actionPublisher(action: PostAction, indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .posts(let groupPost):
            switch action {
            case .likeButtonTapped:
                likeButtonTapped.send(groupPost)
            case .workoutTapped:
                workoutTapped.send(groupPost)
            case .userTapped:
                userTapped.send(groupPost)
            }
        default:
            break
        }
    }
    

}
// MARK: - Delegate - Select Row
extension GroupHomePageDataSource: UITableViewDelegate {
    

}
