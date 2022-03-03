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
    var postSelected = PassthroughSubject<GroupPost,Never>()
    var leaderSelected = PassthroughSubject<Users,Never>()
    var scrolledToHeaderInView = PassthroughSubject<Bool,Never>()
    
    var likeButtonTapped = PassthroughSubject<GroupPost,Never>()
    var workoutTapped = PassthroughSubject<GroupPost,Never>()
    var userTapped = PassthroughSubject<GroupPost,Never>()
    
    var infoCellActionPublisher = PassthroughSubject<GroupInfoCellAction,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    private var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var lastContentOffset: CGFloat = 150
    var headerView: StretchyTableHeaderView!
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
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
                cell.actionPublisher
                    .sink { [weak self] in self?.infoCellActionPublisher.send($0)}
                    .store(in: &self.subscriptions)
                return cell
            case .posts(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: model)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .posts(let post):
            postSelected.send(post)
        case .leader(let leader):
            leaderSelected.send(leader)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 15
        } else if section == 3 {
            return 25
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let label = UILabel()
            label.text = "Created By"
            label.font = .boldSystemFont(ofSize: 12)
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = .lightGray
            return label
        } else if section == 3 {
            let label = UILabel()
            label.text = "POSTS"
            label.font = .boldSystemFont(ofSize: 20)
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = .darkColour
            return label
        } else {
            return nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.scrollViewDidScroll(scrollView: scrollView)
        if lastContentOffset < scrollView.contentOffset.y {
//            delegate.scrolledTo(headerInView: false)
            scrolledToHeaderInView.send(false)
        } else if lastContentOffset > scrollView.contentOffset.y {
//            delegate.scrolledTo(headerInView: true)
            scrolledToHeaderInView.send(true)
        }
    }

}
