//
//  WorkouCollectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class WorkoutsCollectionDataSource: NSObject {
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<Int,WorkoutModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCollectionViewCell.reuseID, for: indexPath) as! WorkoutCollectionViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,WorkoutModel>()
        snapshot.appendSections([1])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [WorkoutModel]) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(models, toSection: 1)
        dataDource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension WorkoutsCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let workout = dataDource.itemIdentifier(for: indexPath) else {return}
        workoutSelected.send(indexPath)
    }
}
