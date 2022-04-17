//
//  ClipDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ClipCollectionDataSource: NSObject {
    
    // MARK: - Publisher
    var clipSelected = PassthroughSubject<WorkoutClipModel, Never>()
    var selectedCell = PassthroughSubject<SelectedClip,Never>()
    
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,WorkoutClipModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DisplayClipCell.reuseID, for: indexPath) as! DisplayClipCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkoutClipModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [WorkoutClipModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

// MARK: - Collection View Delegate
extension ClipCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let clip = dataSource.itemIdentifier(for: indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? ClipCollectionCell,
            let snapshot = cell.thumbnailImageView.snapshotView(afterScreenUpdates: false)
        else {return}
        selectedCell.send(SelectedClip(selectedCell: cell, snapshot: snapshot))
        clipSelected.send(clip)
    }
}
