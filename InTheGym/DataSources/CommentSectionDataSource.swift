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
    var likeButtonTapped = PassthroughSubject<PostModel,Never>()
    
    var userTapped = PassthroughSubject<PostModel,Never>()
    
    var workoutTapped = PassthroughSubject<PostModel,Never>()
    
    var groupPostLikeButtonTapped = PassthroughSubject<GroupPost,Never>()
    
    var groupPostWorkoutButtonTapped = PassthroughSubject<GroupPost,Never>()
    
    var groupUserButtonTapped = PassthroughSubject<GroupPost,Never>()
    
    var commentUserTapped = PassthroughSubject<Comment,Never>()
    
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
                cell.longDateFormat = true
                cell.configure(with: post)
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            case .mainGroupPost(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.longDateFormat = true
                cell.configure(with: post)
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            case .comment(let comment):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.cellID, for: indexPath) as! CommentTableViewCell
                cell.setup(with: comment)
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            }
        }
    }
    // MARK: - Initial Setup
    func initialSetup(with post: PostModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.Post, .comments])
        currentSnapshot.appendItems([.mainPost(post)], toSection: .Post)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Initial Group Setup
    func initialGroupSetup(with post: GroupPost) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.Post, .comments])
        currentSnapshot.appendItems([.mainGroupPost(post)], toSection: .Post)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateComments(with comments: [Comment]) {
        var currentSnapshot = dataSource.snapshot()
        let items = comments.map { GroupCommentItems.comment($0) }
        currentSnapshot.appendItems(items, toSection: .comments)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Add
    func addComment(_ comment: Comment) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([GroupCommentItems.comment(comment)], toSection: .comments)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Reload Main Post
    func reloadMain() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadSections([.Post])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
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
            case .userTapped:
                userTapped.send(post)
            }
        case .mainGroupPost(let groupPost):
            switch action {
            case .likeButtonTapped:
                groupPostLikeButtonTapped.send(groupPost)
            case .workoutTapped:
                groupPostWorkoutButtonTapped.send(groupPost)
            case .userTapped:
                groupUserButtonTapped.send(groupPost)
            }
        case .comment(let comment):
            switch action {
            case .userTapped:
                commentUserTapped.send(comment)
            default:
                break
            }
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
