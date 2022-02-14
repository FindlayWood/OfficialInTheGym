//
//  MyProfileDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MyProfileDataSource: NSObject {
    
    // MARK: - Publisher
    var postSelected = PassthroughSubject<post,Never>()
    var optionSelected = PassthroughSubject<ProfileOptions,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    private lazy var dataSource = makeDataSource()
    var optionSubscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<ProfileSections,ProfileItems> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .userInfo(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileInfoCell.cellID, for: indexPath) as! ProfileInfoCell
                cell.configure(with: model)
                return cell
            case .options:
                self.optionSubscriptions.removeAll()
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileOptionsCell.cellID, for: indexPath) as! ProfileOptionsCell
                cell.optionSelected
                    .sink { [weak self] in self?.optionSelected.send($0) }
                    .store(in: &self.optionSubscriptions)
                return cell
            case .posts(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: model)
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSections,ProfileItems>()
        snapshot.appendSections([.profileOptions, .posts])
        snapshot.appendItems([.options], toSection: .profileOptions)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updatePosts(with models: [post]) {
        let items = models.map { ProfileItems.posts($0) }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .posts)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
//    func updateUser(with user: UserProfileModel) {
//        var currentSnapshot = dataSource.snapshot()
//        currentSnapshot.appendItems([ProfileItems.userInfo(user)], toSection: .mainInfo)
//        dataSource.apply(currentSnapshot, animatingDifferences: false)
//    }
//
//    func reloadUser() {
//        var currentSnapshot = dataSource.snapshot()
//        currentSnapshot.reloadSections([.mainInfo])
//        dataSource.apply(currentSnapshot, animatingDifferences: true)
//    }
}
// MARK: - Delegate - Select Row
extension MyProfileDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 25
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let label = UILabel()
            label.text = "POSTS"
            label.font = .boldSystemFont(ofSize: 20)
            //label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = Constants.darkColour
            return label
        } else {
            return UIView()
        }
    }
}



// MARK: - Profile Options Data Source
class ProfileOptionsDataSource: NSObject {
    
    // MARK: - Publisher
    var optionSelected = PassthroughSubject<ProfileOptions,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ProfileOptions> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionsCollectionCell.reuseID, for: indexPath) as! OptionsCollectionCell
            cell.configure(with: itemIdentifier.image)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ProfileOptions>()
        snapshot.appendSections([.main])
        snapshot.appendItems(ProfileOptions.allCases, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func update(with options: [ProfileOptions]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(options, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
extension ProfileOptionsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let option = dataSource.itemIdentifier(for: indexPath) else {return}
        optionSelected.send(option)
    }
}
