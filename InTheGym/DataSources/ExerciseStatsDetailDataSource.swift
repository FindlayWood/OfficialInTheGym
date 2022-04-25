//
//  ExerciseStatsDetailDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseStatsDetailDataSource: NSObject {
    
    // MARK: - Publisher
    
    // MARK: - Properties
    var collectionView: UICollectionView
    var model: ExerciseStatsModel
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView, model: ExerciseStatsModel) {
        self.collectionView = collectionView
        self.model = model
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ClipModel> {
        let dataSource = UICollectionViewDiffableDataSource<SingleSection, ClipModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseClipsCollectionCell.reuseID, for: indexPath) as! ExerciseClipsCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            
            guard kind == UICollectionView.elementKindSectionHeader else {return nil}
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ExerciseStatsDetailHeaderView.reuseIdentifier, for: indexPath) as? ExerciseStatsDetailHeaderView
            view?.configure(with: self.model)
            return view
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ClipModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    func updateClips(with models: [ClipModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate
extension ExerciseStatsDetailDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
    }
}

