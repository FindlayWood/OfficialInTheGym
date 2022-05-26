//
//  ExerciseTagDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseTagDataSource: NSObject {
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ExerciseTagReturnModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseTagCell.reuseID, for: indexPath) as! ExerciseTagCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseTagReturnModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseTagReturnModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseTagReturnModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
