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
    private var searchDelegate: UISearchBarDelegate
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView, searchDelegate: UISearchBarDelegate) {
        self.collectionView = collectionView
        self.searchDelegate = searchDelegate
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,WorkoutModel> {
        
        let dataSource = UICollectionViewDiffableDataSource<SingleSection,WorkoutModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCollectionViewCell.reuseID, for: indexPath) as! WorkoutCollectionViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DisplayWorkoutsCollectionHeader.reuseIdentifier, for: indexPath) as? DisplayWorkoutsCollectionHeader
            view?.searchField.delegate = self.searchDelegate
            return view
            
        }
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkoutModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [WorkoutModel]) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkoutModel>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Reload
    func reloadModel(_ model: WorkoutModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadItems([model])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
// MARK: - Delegate - Select Row
extension WorkoutsCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let workout = dataSource.itemIdentifier(for: indexPath) else {return}
        workoutSelected.send(workout)
    }
}
