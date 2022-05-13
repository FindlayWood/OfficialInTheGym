//
//  WorkoutCollectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class WorkoutCollectionDataSource: NSObject {
    // MARK: - Publisher
    var completeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var setSelected = PassthroughSubject<SelectedSetCell,Never>()
    var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    var isUserInteractionEnabled: Bool
    
    // MARK: - Initializer
    init(collectionView: UICollectionView, isUserInteractionEnabled: Bool) {
        self.collectionView = collectionView
        self.isUserInteractionEnabled = isUserInteractionEnabled
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ExerciseSet> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainWorkoutCollectionCell.reuseID, for: indexPath) as! MainWorkoutCollectionCell
            cell.configure(with: itemIdentifier)
            cell.setUserInteraction(to: self.isUserInteractionEnabled)
            self.subscriptions[indexPath] = cell.completeButtonTapped
                .sink(receiveValue: { [weak self] in
                    self?.completeButtonTapped.send(indexPath)
                })
            //cell.layoutIfNeeded()
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseSet>()
        snapshot.appendSections([.main])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseSet]) {
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
}
// MARK: - CollectionView Delegate
extension WorkoutCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataDource.itemIdentifier(for: indexPath) else {return}
        if let cell = collectionView.cellForItem(at: indexPath) as? MainWorkoutCollectionCell {
            let snapshot = cell.snapshotView(afterScreenUpdates: false)
            setSelected.send(SelectedSetCell(cell: cell, snapshot: snapshot, setModel: item))
        }
    }
}
