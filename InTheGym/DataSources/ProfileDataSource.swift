//
//  ProfileDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileDataSource: NSObject {
    
    // MARK: - Publisher
    @Published var selectedIndex: Int = 0
    var itemSelected = PassthroughSubject<ProfilePageItems,Never>()
    var cellSelected = PassthroughSubject<SelectedClip,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var publicProfile: Bool = false
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<ProfilePageSections,ProfilePageItems> {
        let dataSource = UICollectionViewDiffableDataSource<ProfilePageSections, ProfilePageItems>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .workout(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedWorkoutCollectionCell.reuseID, for: indexPath) as! SavedWorkoutCollectionCell
                cell.configure(with: model)
                return cell
            case .profileInfo(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoCollectionViewCell.reuseID, for: indexPath) as! ProfileInfoCollectionViewCell
                cell.configure(with: model)
                if self.publicProfile {
                    cell.infoView.setFollowButton(to: .loading)
                }
                return cell
            case .post(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.reuseID, for: indexPath) as! PostCollectionViewCell
                cell.configure(with: model)
                return cell
            case .clip(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseClipsCollectionCell.reuseID, for: indexPath) as! ExerciseClipsCollectionCell
                cell.configure(with: model)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            
            guard kind == UICollectionView.elementKindSectionHeader,
                  indexPath.section == 1
            else {
                return nil
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.reuseIdentifier, for: indexPath) as? ProfileHeaderView
            view?.segmentControl.selectedIndex
                .sink { [weak self] newIndex in
                    
                    self?.selectedIndex = newIndex
//                    self?.reloadSection()
                }
                .store(in: &self.subscriptions)
            return view
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<ProfilePageSections,ProfilePageItems>()
        snapshot.appendSections(ProfilePageSections.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
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
    func updatePosts(with models: [post]) {
        let items = models.map { ProfilePageItems.post($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([.UserData])
        currentSnapshot.appendSections([.UserData])
        currentSnapshot.appendItems(items, toSection: .UserData)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Update Workouts
    func updateWorkouts(with models: [SavedWorkoutModel]) {
        let items = models.map { ProfilePageItems.workout($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([.UserData])
        currentSnapshot.appendSections([.UserData])
        currentSnapshot.appendItems(items, toSection: .UserData)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    
    // MARK: - Update Clips
    func updateClips(with models: [ClipModel]) {
        let items = models.map { ProfilePageItems.clip($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([.UserData])
        currentSnapshot.appendSections([.UserData])
        currentSnapshot.appendItems(items, toSection: .UserData)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: -
    func reloadSection() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([.UserData])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate
extension ProfileDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExerciseClipsCollectionCell {
            let snapshot = cell.thumbnailImageView.snapshotView(afterScreenUpdates: false)
            cellSelected.send(SelectedClip(selectedCell: cell, snapshot: snapshot))
        }
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        itemSelected.send(item)
    }
}


struct SelectedClip {
    var selectedCell: ClipCollectionCell?
    var snapshot: UIView?
}
