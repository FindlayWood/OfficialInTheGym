//
//  OptionsCollectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class OptionsCollectionDataSource: NSObject {
    
    // MARK: - Publisher
    var optionSelected = PassthroughSubject<Options,Never>()
    
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,Options> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionsCell.reuseID, for: indexPath) as! OptionsCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,Options>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [Options]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Remove
    func remove(_ option: Options) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems([option])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

extension OptionsCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        optionSelected.send(item)
    }
}
