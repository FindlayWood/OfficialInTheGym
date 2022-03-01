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
    var postSelcted = PassthroughSubject<post,Never>()
    var scrollPublisher = PassthroughSubject<Bool,Never>()
    
    var likeButtonTapped = PassthroughSubject<post,Never>()
    
    var userTapped = PassthroughSubject<Users,Never>()
    
    var workoutTapped = PassthroughSubject<post,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    var lastContentOffset: CGFloat = 0
    
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
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,post> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
            cell.configure(with: itemIdentifier)
            self.actionSubscriptions.removeValue(forKey: indexPath)
            self.actionSubscriptions[indexPath] = cell.actionPublisher
                .sink(receiveValue: { [weak self] action in
                    self?.actionPublisher(action: action, indexPath: indexPath)
                })
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,post>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [post]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Add
    func addNewPost(_ newPost: post) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([newPost], toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Reload
    func reloadPost(_ reloadPost: post) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadItems([reloadPost])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Actions
    func actionPublisher(action: PostAction, indexPath: IndexPath) {
        guard let post = dataSource.itemIdentifier(for: indexPath) else {return}
        switch action {
        case .likeButtonTapped:
            likeButtonTapped.send(post)
        case .workoutTapped:
            workoutTapped.send(post)
        case .userTapped(let user):
            userTapped.send(user)
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
        if lastContentOffset + 100 < scrollView.contentOffset.y {
            //delegate.hideTopView()
            scrollPublisher.send(false)
        } else if lastContentOffset > scrollView.contentOffset.y {
            //delegate.showTopView()
            scrollPublisher.send(true)
        } else if scrollView.contentOffset.y == 0 {
            //delegate.showTopView()
            scrollPublisher.send(true)
        }
    }
}
