//
//  ExerciseClipsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ExerciseClipsDataSource: NSObject {
    
    // MARK: - Publisher
    var clipSelected = PassthroughSubject<ClipModel,Never>()
    var scrollPublisher = PassthroughSubject<CGFloat,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ClipModel> {
        return UICollectionViewDiffableDataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseClipsCollectionCell.reuseID, for: indexPath) as! ExerciseClipsCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ClipModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ClipModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ClipModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    func updateCollection(with models: [ClipModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ClipModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Item
extension ExerciseClipsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        clipSelected.send(model)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPublisher.send(scrollView.contentOffset.y)
    }

}
