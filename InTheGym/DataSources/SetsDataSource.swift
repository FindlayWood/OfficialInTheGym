//
//  SetsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SetsDataSource: NSObject {
    
    // MARK: - Publisher
    var setSelected = CurrentValueSubject<Int?,Never>(nil)
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    var isLive: Bool = false
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
        self.initSubscriptions()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,SetCellModel> {
        let dataSource = UICollectionViewDiffableDataSource<SingleSection, SetCellModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepsCell.cellID, for: indexPath) as! RepsCell
            cell.configure(with: itemIdentifier)
            if indexPath.item == self.setSelected.value {
                cell.backgroundColor = .darkColour
            }
            return cell
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,SetCellModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update Collection
    func updateCollection(with models: [SetCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,SetCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Append Item
    func appendItem(_ model: SetCellModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([model], toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        setSelected
            .sink { [weak self] setSelected in
                self?.collectionView.reloadData()
                if let set = setSelected {
                    self?.collectionView.scrollToItem(at: IndexPath(item: set, section: 0), at: .centeredHorizontally, animated: true)
                }
                
            }.store(in: &subscriptions)
    }
}

// MARK: - Delegate
extension SetsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLive {
            if setSelected.value == indexPath.item {
                setSelected.send(nil)
            } else {
                setSelected.send(indexPath.item)
            }
        }
    }
}
