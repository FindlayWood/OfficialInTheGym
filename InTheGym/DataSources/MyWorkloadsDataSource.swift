//
//  MyWorkloadsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyWorkloadsDataSource: NSObject {
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,WorkloadModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWorkloadCollectionCell.reuseID, for: indexPath) as! MyWorkloadCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    // MARK: - Update
    func updateTable(with models: [WorkloadModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,WorkloadModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
