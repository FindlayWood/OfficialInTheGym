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
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,WorkoutModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCollectionViewCell.reuseID, for: indexPath) as! WorkoutCollectionViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkoutModel>()
        snapshot.appendSections([.main])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [WorkoutModel]) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkoutModel>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(models, toSection: .main)
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Reload
    func reloadModel(_ model: WorkoutModel) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.reloadItems([model])
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
}
// MARK: - Delegate - Select Row
extension WorkoutsCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let workout = dataDource.itemIdentifier(for: indexPath) else {return}
        workoutSelected.send(workout)
    }
}
