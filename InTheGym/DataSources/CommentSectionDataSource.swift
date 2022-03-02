//
//  CommentSectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class CommentSectionDataSource: NSObject {
    // MARK: - Publisher
    var likeButtonTapped = PassthroughSubject<post,Never>()
    
    var userTapped = PassthroughSubject<Users,Never>()
    
    var workoutTapped = PassthroughSubject<post,Never>()
    
    var groupPostLikeButtonTapped = PassthroughSubject<GroupPost,Never>()
    
    var groupPostWorkoutButtonTapped = PassthroughSubject<GroupPost,Never>()
    
    var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Properties
    var tableView: UITableView
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<CommentSectionSections,GroupCommentItems> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .mainPost(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: post)
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            case .mainGroupPost(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: post)
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            case .comment(let comment):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.cellID, for: indexPath) as! CommentTableViewCell
                cell.setup(with: comment)
                return cell
            }
        }
    }
    // MARK: - Initial Setup
    func initialSetup(with post: post) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.Post, .comments])
        currentSnapshot.appendItems([.mainPost(post)], toSection: .Post)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Initial Group Setup
    func initialGroupSetup(with post: GroupPost) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.Post, .comments])
        currentSnapshot.appendItems([.mainGroupPost(post)], toSection: .Post)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update
    func updateComments(with comments: [Comment]) {
        var currentSnapshot = dataSource.snapshot()
        let items = comments.map { GroupCommentItems.comment($0) }
        currentSnapshot.appendItems(items, toSection: .comments)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Actions
    func actionPublisher(action: PostAction, indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .mainPost(let post):
            switch action {
            case .likeButtonTapped:
                likeButtonTapped.send(post)
            case .workoutTapped:
                workoutTapped.send(post)
            case .userTapped(let user):
                userTapped.send(user)
            }
        case .mainGroupPost(let groupPost):
            switch action {
            case .likeButtonTapped:
                groupPostLikeButtonTapped.send(groupPost)
            case .workoutTapped:
                groupPostWorkoutButtonTapped.send(groupPost)
            case .userTapped(let user):
                userTapped.send(user)
            }
        case .comment(_):
            break
        }

    }
}

extension CommentSectionDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
}
