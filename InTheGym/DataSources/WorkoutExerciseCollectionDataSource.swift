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
    var exerciseButtonTapped = PassthroughSubject<ExerciseModel,Never>()
    var showClipPublisher = PassthroughSubject<Bool,Never>()
    var setSelected = PassthroughSubject<(SelectedSetCell,ExerciseModel?),Never>()
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    private lazy var dataDource = makeDataSource()
    var lastContentOffset: CGFloat = 0
    var isUserInteractionEnabled: Bool = false
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,ExerciseRow> {
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
                        case .setSelected(let setModel):
                            self?.setSelected.send((setModel,self?.getExercise(at: indexPath)))
                        case .noteButton:
                            self?.noteButtonTapped.send(indexPath)
                        case .rpeButton:
                            self?.rpeButtonTapped.send(indexPath)
                        case .clipButton:
                            guard let exercise = self?.getExercise(at: indexPath) else {return}
                            self?.clipButtonTapped.send(exercise)
                        case .exerciseButton:
                            guard let model = self?.getExercise(at: indexPath) else {return}
                            self?.exerciseButtonTapped.send(model)
                        case .completed(let tappedIndex):
                            let fullIndex = IndexPath(item: tappedIndex.item, section: indexPath.item)
                            self?.completeButtonTapped.send(fullIndex)
                        }
                    })
                return cell
            }
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseRow>()
        snapshot.appendSections([.main])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseType]) {
        var currentSnapshot = dataDource.snapshot()
        for type in models {
            switch type {
            case is ExerciseModel:
                currentSnapshot.appendItems([.exercise(type as! ExerciseModel)], toSection: .main)
            default:
                break
            }
        }
        dataDource.apply(currentSnapshot, animatingDifferences: false)
    }
    func update(for exercise: ExerciseModel) {
        var offset: CGPoint = .zero
        let indexPath = IndexPath(item: exercise.workoutPosition, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ExerciseCollectionCell {
            offset = cell.collectionView.contentOffset
        }
        guard let item = dataDource.itemIdentifier(for: IndexPath(item: exercise.workoutPosition, section: 0)) else {return}
        var currentSnapshot = dataDource.snapshot()
        currentSnapshot.insertItems([ExerciseRow.exercise(exercise)], afterItem: item)
        currentSnapshot.deleteItems([item])
        dataDource.apply(currentSnapshot, animatingDifferences: false)
        if let cell = collectionView.cellForItem(at: indexPath) as? ExerciseCollectionCell {
            cell.collectionView.setContentOffset(offset, animated: false)
        }
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
    
    // MARK: - Action
    func action(action: ExerciseAction, indexPath: IndexPath) {
        
    }
}
// MARK: - Delegate - Select Row
extension WorkoutExerciseCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let rowSelected = dataDource.itemIdentifier(for: indexPath) else {return}
        switch rowSelected {
        case .exercise(_):
            break
        }
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



