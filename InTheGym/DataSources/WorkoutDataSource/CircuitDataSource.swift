//
//  CircuitDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

/// data source for displaying a circuit
class CircuitDataSource {
    // MARK: - Publishers
    var exerciseNameButtonAction = PassthroughSubject<CircuitTableModel,Never>()
    var completeButtonAction = PassthroughSubject<IndexPath,Never>()
    // MARK: - Properties
    var collectionView: UICollectionView
    lazy var dataSource = makeDataSource()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,CircuitTableModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircuitCollectionViewCell.reuseID, for: indexPath) as? CircuitCollectionViewCell
            cell?.configure(with: itemIdentifier)
            cell?.actionPublisher
                .sink { [weak self] action in
                    switch action {
                    case .exerciseButton:
                        self?.exerciseNameButtonAction.send(itemIdentifier)
                    case .completeButton:
                        self?.completeButtonAction.send(indexPath)
                    }
                }
                .store(in: &self.subscriptions)
            return cell
        }
    }
    // MARK: - Update Collection
    func updateCollection(with models: [CircuitTableModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,CircuitTableModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    func updateCell(newCell: CircuitTableModel, at index: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: index) else {return}
        var newCell = newCell
        var snapshot = dataSource.snapshot()
        snapshot.insertItems([newCell], afterItem: item)
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
