//
//  ExerciseMaxHistoryDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseMaxHistoryDataSource: NSObject {
    // MARK: - Publishers
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
    }
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ExerciseMaxHistoryModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseMaxHistoryCollectionCell.reuseID, for: indexPath) as! ExerciseMaxHistoryCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    // MARK: - Update
    func updateTable(with models: [ExerciseMaxHistoryModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseMaxHistoryModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
