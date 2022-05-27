//
//  ProfileTableViewDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileTableViewDataSource: NSObject {
    
    // MARK: - Publisher
    @Published var selectedIndex: Int = 0
    var itemSelected = PassthroughSubject<ProfilePageItems,Never>()
    var cellSelected = PassthroughSubject<SelectedClip,Never>()
    var postSelected = PassthroughSubject<PostModel,Never>()
    var profileInfoAction = PassthroughSubject<ProfileInfoActions,Never>()
    
    var likeButtonTapped = PassthroughSubject<PostModel,Never>()
    
    var userTapped = PassthroughSubject<PostModel,Never>()
    
    var workoutTapped = PassthroughSubject<PostModel,Never>()
    
    var currentOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var publicProfile: Bool = false
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<ProfilePageSections,ProfilePageItems> {
        let dataSource = UITableViewDiffableDataSource<ProfilePageSections, ProfilePageItems>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .profileInfo(let user):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileInfoTableViewCell.cellID, for: indexPath) as? ProfileInfoTableViewCell
                cell?.configure(with: user)
                if self.publicProfile {
                    cell?.infoView.setFollowButton(to: .loading)
                }
                self.actionSubscriptions[indexPath] = cell?.actionPublisher
                    .sink { [weak self] in self?.profileInfoAction.send($0)}
                return cell
            case .post(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as? PostTableViewCell
                cell?.configure(with: post)
                self.actionSubscriptions[indexPath] = cell?.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        self?.actionPublisher(action: action, indexPath: indexPath)
                    })
                return cell
            case .spacer:
                let cell = tableView.dequeueReusableCell(withIdentifier: SpacerCell.cellID, for: indexPath) as? SpacerCell
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<ProfilePageSections,ProfilePageItems>()
        snapshot.appendSections([.UserInfo,.UserData])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func fullUpdate(user: Users, posts: [PostModel]) {
        currentOffset = tableView.contentOffset
        var snapshot = NSDiffableDataSourceSnapshot<ProfilePageSections,ProfilePageItems>()
        snapshot.appendSections([.UserInfo,.UserData])
        snapshot.appendItems([.profileInfo(user)], toSection: .UserInfo)
        let items = posts.map { ProfilePageItems.post($0)}
        snapshot.appendItems(items, toSection: .UserData)
        dataSource.apply(snapshot, animatingDifferences: false)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    // MARK: - Update User Info
    func updateUserInfo(with user: Users) {
        let items = ProfilePageItems.profileInfo(user)
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([items], toSection: .UserInfo)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updatePublicUserInfo(with user: Users) {
        publicProfile = true
        let items = ProfilePageItems.profileInfo(user)
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([items], toSection: .UserInfo)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Update Posts
    func updatePosts(with models: [PostModel]) {
        currentOffset = tableView.contentOffset
        let items = models.map { ProfilePageItems.post($0)}
        var currentSnapshot = dataSource.snapshot()
        let currentItems = currentSnapshot.itemIdentifiers(inSection: .UserData)
        currentSnapshot.deleteItems(currentItems)
        if items.isEmpty {
            currentSnapshot.appendItems([.spacer], toSection: .UserData)
        } else {
            currentSnapshot.appendItems(items, toSection: .UserData)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    func addSpacerCell() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([.Spacer])
        currentSnapshot.appendSections([.Spacer])
        currentSnapshot.appendItems([.spacer], toSection: .Spacer)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: -
    func reloadSection() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadSections([.UserInfo])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Actions
    func actionPublisher(action: PostAction, indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .profileInfo(_):
            break // may include follow button - but it may bi en cell VM
        case .post(let post):
            switch action {
            case .likeButtonTapped:
                likeButtonTapped.send(post)
            case .workoutTapped:
                workoutTapped.send(post)
            case .userTapped:
                userTapped.send(post)
            }
        case .workout(_):
            break
        case .clip(_):
            break
        case .spacer:
            break
        }

    }
}

// MARK: - Delegate
extension ProfileTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .post(let post):
            postSelected.send(post)
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = ProfileHeaderView()
            view.segmentControl.selectedIndex
                .sink { [weak self] in self?.selectedIndex = $0 }
                .store(in: &subscriptions)
            return view
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
}
