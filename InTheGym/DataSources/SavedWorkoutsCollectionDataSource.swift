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
    var workoutSelected = PassthroughSubject<IndexPath,Never>()
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<Int,SavedWorkoutModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedWorkoutCollectionCell.reuseID, for: indexPath) as! SavedWorkoutCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
//        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
//            let cell = tableView.dequeueReusableCell(withIdentifier: SavedWorkoutTableViewCell.cellID, for: indexPath) as! SavedWorkoutTableViewCell
//            cell.configure(with: itemIdentifier)
//            return cell
//        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,SavedWorkoutModel>()
        snapshot.appendSections([1])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [SavedWorkoutModel]) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(models, toSection: 1)
        dataDource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension SavedWorkoutsCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        workoutSelected.send(indexPath)
    }
}
