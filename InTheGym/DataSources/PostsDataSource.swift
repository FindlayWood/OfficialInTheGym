//
//  PostsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PostsDataSource: NSObject {
    
    // MARK: - Publisher
    var postSelcted = PassthroughSubject<PostModel,Never>()
    
    var scrollPublisher = PassthroughSubject<CGFloat,Never>()
    
    var draggedPublihser = PassthroughSubject<CGFloat,Never>()
    
    var likeButtonTapped = PassthroughSubject<PostModel,Never>()
    
    var userTapped = PassthroughSubject<PostModel,Never>()
    
    var workoutTapped = PassthroughSubject<PostModel,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    var lastContentOffset: CGFloat = 0
    
    var lastGestureOffset: CGFloat = 0
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,PostModel> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
            cell.longDateFormat = false
            cell.configure(with: itemIdentifier)
            self.actionSubscriptions[indexPath] = cell.actionPublisher
                .sink(receiveValue: { [weak self] action in
                    self?.actionPublisher(action: action, indexPath: indexPath)
                })
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,PostModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [PostModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,PostModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Add
    func addNewPost(_ newPost: PostModel) {
        var currentSnapshot = dataSource.snapshot()
        if let firstItem = currentSnapshot.itemIdentifiers.first {
            currentSnapshot.insertItems([newPost], beforeItem: firstItem)
        } else {
            currentSnapshot.appendItems([newPost], toSection: .main)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Reload
    func reloadPost(_ reloadPost: PostModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadItems([reloadPost])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Actions
    func actionPublisher(action: PostAction, indexPath: IndexPath) {
        var currentSnapshot = dataSource.snapshot()
        guard let post = dataSource.itemIdentifier(for: indexPath) else {return}
        switch action {
        case .likeButtonTapped:
            var newPost = post
            newPost.likeCount += 1
            currentSnapshot.insertItems([newPost], afterItem: post)
            currentSnapshot.deleteItems([post])
            dataSource.apply(currentSnapshot,animatingDifferences: false)
        case .workoutTapped:
            workoutTapped.send(post)
        case .userTapped:
            userTapped.send(post)
        }
    }
}
// MARK: - Delegate - Select Row
extension PostsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let post = dataSource.itemIdentifier(for: indexPath) else {return}
        postSelcted.send(post)
    }
    
    // MARK: - Check Scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPublisher.send(scrollView.contentOffset.y)
        if lastContentOffset < scrollView.contentOffset.y {
            //delegate.hideTopView()
//            print("first one: \(lastContentOffset)")
//            scrollPublisher.send(false)
        } else if lastContentOffset > scrollView.contentOffset.y {
//            print("second one: \(lastContentOffset)")
            //delegate.showTopView()
//            scrollPublisher.send(true)
        } else if scrollView.contentOffset.y == 0 {
            //delegate.showTopView()
//            scrollPublisher.send(true)
        }
    }
}
