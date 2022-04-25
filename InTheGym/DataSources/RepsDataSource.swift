//
//  RepsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

import UIKit
import Combine

class RepsDataSource: NSObject {
    
    // MARK: - Publisher
    var repSelected = CurrentValueSubject<Int,Never>(1)
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    var selectedIndex: Int = 1
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,Int> {
        let dataSource = UICollectionViewDiffableDataSource<SingleSection, Int>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetsCell.cellID, for: indexPath) as! SetsCell
            cell.configure(with: itemIdentifier)
            if indexPath.item == self.repSelected.value {
                cell.backgroundColor = .darkColour
            }
            return cell
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(SetsCell.repNumbers, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        repSelected
            .sink { [weak self] rep in
                self?.collectionView.reloadData()
                self?.collectionView.scrollToItem(at: IndexPath(item: rep, section: 0), at: .centeredHorizontally, animated: true)
            }.store(in: &subscriptions)
    }
}

// MARK: - Delegate
extension RepsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        repSelected.send(indexPath.item)
    }
}
