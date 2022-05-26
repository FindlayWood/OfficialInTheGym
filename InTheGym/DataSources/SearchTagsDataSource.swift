//
//  SearchTagsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SearchTagsDataSource: NSObject {
    
    // MARK: - Publishers
    var itemSelected = PassthroughSubject<TagAndExerciseCellModel,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,TagAndExerciseCellModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagAndExerciseCell.reuseID, for: indexPath) as! TagAndExerciseCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Update
    func updateTable(with models: [TagAndExerciseCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,TagAndExerciseCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate
extension SearchTagsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        itemSelected.send(item)
    }
}
