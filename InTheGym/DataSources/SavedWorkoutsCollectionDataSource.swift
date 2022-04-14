//
//  SavedWorkoutsCollectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//


import Foundation
import UIKit
import Combine

class SavedWorkoutsCollectionDataSource: NSObject {
    
    // MARK: - Publisher
    var workoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var scrollPublisher = PassthroughSubject<CGFloat,Never>()
    
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,SavedWorkoutModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedWorkoutCollectionCell.reuseID, for: indexPath) as! SavedWorkoutCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,SavedWorkoutModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [SavedWorkoutModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Remove
    func removeWorkout(_ model: SavedWorkoutModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems([model])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension SavedWorkoutsCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let workout = dataSource.itemIdentifier(for: indexPath) else {return}
        workoutSelected.send(workout)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPublisher.send(scrollView.contentOffset.y)
    }
}
