//
//  LiveWorkoutDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class LiveWorkoutDataSource: NSObject {
    
    // MARK: - Publisher
    var rowSelected = PassthroughSubject<ExerciseRow,Never>()
    var completeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var rpeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var noteButtonTapped = PassthroughSubject<IndexPath,Never>()
    var clipButtonTapped = PassthroughSubject<IndexPath,Never>()
    var exerciseButtonTapped = PassthroughSubject<IndexPath,Never>()
    var showClipPublisher = PassthroughSubject<Bool,Never>()
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    var plusExerciseButtonTapped = PassthroughSubject<Void,Never>()
    var plusSetButtonTapped = PassthroughSubject<IndexPath,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    var lastContentOffset: CGFloat = 0
    var isUserInteractionEnabled: Bool
    
    // MARK: - Initializer
    init(collectionView: UICollectionView, isUserInteractionEnabled: Bool) {
        self.collectionView = collectionView
        self.isUserInteractionEnabled = isUserInteractionEnabled
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<LiveWorkoutSections,LiveWorkoutItems> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exercise(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveExerciseCollectionCell.reuseID, for: indexPath) as! LiveExerciseCollectionCell
                cell.setUserInteraction(to: self.isUserInteractionEnabled)
                cell.interactionEnabled = self.isUserInteractionEnabled
                cell.configure(with: model)
                self.actionSubscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        switch action {
                        case .noteButton:
                            self?.noteButtonTapped.send(indexPath)
                        case .rpeButton:
                            self?.rpeButtonTapped.send(indexPath)
                        case .clipButton:
                            self?.clipButtonTapped.send(indexPath)
                        case .exerciseButton:
                            self?.exerciseButtonTapped.send(indexPath)
                        case .addSet:
                            self?.plusSetButtonTapped.send(indexPath)
                        }
                    })
                return cell
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID, for: indexPath) as! LiveWorkoutPlusCollectionCell
                self.actionSubscriptions[indexPath] = cell.plusTappedPublisher
                    .sink(receiveValue: { [weak self] in
                        self?.plusExerciseButtonTapped.send(())
                    })
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<LiveWorkoutSections,LiveWorkoutItems>()
        snapshot.appendSections([.exercise, .plus])
        if isUserInteractionEnabled {
            snapshot.appendItems([.plus], toSection: .plus)
        }
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with exercises: [ExerciseModel]) {
        let items = exercises.map { LiveWorkoutItems.exercise($0) }
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.appendItems(items, toSection: .exercise)
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
}
// MARK: - Delegate - Select Row
extension LiveWorkoutDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset + 100 < scrollView.contentOffset.y {
            showClipPublisher.send(false)
        } else if lastContentOffset > scrollView.contentOffset.y {
            showClipPublisher.send(true)
        } else if scrollView.contentOffset.y == 0 {
            showClipPublisher.send(true)
        }
    }
}



