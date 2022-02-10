//
//  WorkoutExerciseCollectionDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class WorkoutExerciseCollectionDataSource: NSObject {
    
    // MARK: - Publisher
    var rowSelected = PassthroughSubject<ExerciseRow,Never>()
    var completeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var rpeButtonTapped = PassthroughSubject<IndexPath,Never>()
    var noteButtonTapped = PassthroughSubject<IndexPath,Never>()
    var clipButtonTapped = PassthroughSubject<ExerciseModel,Never>()
    var exerciseButtonTapped = PassthroughSubject<IndexPath,Never>()
    var showClipPublisher = PassthroughSubject<Bool,Never>()
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
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
    func makeDataSource() -> UICollectionViewDiffableDataSource<Int,ExerciseRow> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exercise(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseCollectionCell.reuseID, for: indexPath) as! ExerciseCollectionCell
                cell.userInteraction = self.isUserInteractionEnabled
                cell.setUserInteraction(to: self.isUserInteractionEnabled)
                cell.configure(with: model)
                self.actionSubscriptions[indexPath] = cell.actionPublisher
                    .sink(receiveValue: { [weak self] action in
                        switch action {
                        case .noteButton:
                            self?.noteButtonTapped.send(indexPath)
                        case .rpeButton:
                            self?.rpeButtonTapped.send(indexPath)
                        case .clipButton:
                            guard let exercise = self?.getExercise(at: indexPath) else {return}
                            self?.clipButtonTapped.send(exercise)
                        case .exerciseButton:
                            self?.exerciseButtonTapped.send(indexPath)
                        case .completed(let tappedIndex):
                            let fullIndex = IndexPath(item: tappedIndex.item, section: indexPath.item)
                            self?.completeButtonTapped.send(fullIndex)
                        }
                    })
                return cell
            case .circuit(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainWorkoutCircuitCollectionCell.reuseID, for: indexPath) as! MainWorkoutCircuitCollectionCell
                cell.configure(with: model)
                return cell
            case .emom(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainWorkoutEMOMCollectionCell.reuseID, for: indexPath) as! MainWorkoutEMOMCollectionCell
                cell.configure(with: model)
                return cell
            case .amrap(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainWorkoutAMRAPCollectionCell.reuseID, for: indexPath) as! MainWorkoutAMRAPCollectionCell
                cell.configure(with: model)
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,ExerciseRow>()
        snapshot.appendSections([1])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseType]) {
        var currentSnapshot = dataDource.snapshot()
        for type in models {
            switch type {
            case is ExerciseModel:
                currentSnapshot.appendItems([.exercise(type as! ExerciseModel)], toSection: 1)
            case is CircuitModel:
                currentSnapshot.appendItems([.circuit(type as! CircuitModel)], toSection: 1)
            case is EMOMModel:
                currentSnapshot.appendItems([.emom(type as! EMOMModel)], toSection: 1)
            case is AMRAPModel:
                currentSnapshot.appendItems([.amrap(type as! AMRAPModel)], toSection: 1)
            default:
                break
            }
        }
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Retreive
    func getExercise(at indexPath: IndexPath) -> ExerciseModel? {
        guard let exercise = dataDource.itemIdentifier(for: indexPath) else {return nil}
        switch exercise {
        case .exercise(let exerciseModel):
            return exerciseModel
        default:
            return nil
        }
    }
}
// MARK: - Delegate - Select Row
extension WorkoutExerciseCollectionDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selected = dataDource.itemIdentifier(for: indexPath) else {return}
        rowSelected.send(selected)
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



