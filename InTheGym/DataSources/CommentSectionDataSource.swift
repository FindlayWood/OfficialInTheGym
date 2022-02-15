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
    var userSelected = PassthroughSubject<Users,Never>()
    var workoutSelected = PassthroughSubject<IndexPath,Never>()
    var likeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Properties
    var tableView: UITableView
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
//        self.tableView.delegate = self
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
                        switch action {
                        case .userTapped(let user):
                            self?.userSelected.send(user)
                        case .workoutTapped:
                            self?.workoutSelected.send(indexPath)
                        case .likeButtonTapped:
                            self?.likeButtonTapped.send(indexPath)
                        }
                    })
                return cell
            case .mainGroupPost(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: post)
//                cell.delegate = self
                self.subscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        switch action {
                        case .userTapped(let user):
                            self?.userSelected.send(user)
                        case .workoutTapped:
                            self?.workoutSelected.send(indexPath)
                        case .likeButtonTapped:
                            self?.likeButtonTapped.send(indexPath)
                        }
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
//        for comment in comments {
//            currentSnapshot.appendItems([.comment(comment)], toSection: .comments)
//        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

