//
//  LiveWorkoutSetDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class LiveWorkoutSetDataSource: NSObject {
    // MARK: - Publisher
    var subscriptions = [IndexPath: AnyCancellable]()
    var plusButtonTapped = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    var isUserInteractionEnabled: Bool
    
    // MARK: - Initializer
    init(collectionView: UICollectionView, isUserInteractionEnabled: Bool) {
        self.collectionView = collectionView
        self.isUserInteractionEnabled = isUserInteractionEnabled
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<LiveWorkoutSections,LiveWorkoutSetItems> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exerciseSet(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainWorkoutCollectionCell.reuseID, for: indexPath) as! MainWorkoutCollectionCell
                cell.configure(with: model)
                cell.setUserInteraction(to: false)
                return cell
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID, for: indexPath) as! LiveWorkoutPlusCollectionCell
                self.subscriptions[indexPath] = cell.plusTappedPublisher
                    .sink(receiveValue: { [weak self] in
                        self?.plusButtonTapped.send(())
                    })
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<LiveWorkoutSections,LiveWorkoutSetItems>()
        snapshot.appendSections([.exercise, .plus])
        if isUserInteractionEnabled {
            snapshot.appendItems([.plus], toSection: .plus)
        }
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseSet]) {
        let items = models.map { LiveWorkoutSetItems.exerciseSet($0) }
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(items, toSection: .exercise)
        dataDource.apply(currentSnapshot, animatingDifferences: true)
    }
}
