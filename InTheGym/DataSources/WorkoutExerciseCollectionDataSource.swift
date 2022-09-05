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
    var amrapSelected = PassthroughSubject<AMRAPModel,Never>()
    var emomSelected = PassthroughSubject<EMOMModel,Never>()
    var circuitSelected = PassthroughSubject<CircuitModel,Never>()
    
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
            case is CircuitModel:
                currentSnapshot.appendItems([.circuit(type as! CircuitModel)], toSection: .main)
            case is EMOMModel:
                currentSnapshot.appendItems([.emom(type as! EMOMModel)], toSection: .main)
            case is AMRAPModel:
                currentSnapshot.appendItems([.amrap(type as! AMRAPModel)], toSection: .main)
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
    // MARK: - Update Functions
    func updateCircuit(_ newCircuit: CircuitModel) {
        guard let item = dataDource.itemIdentifier(for: IndexPath(item: newCircuit.workoutPosition, section: 0)) else {return}
        var snapshot = dataDource.snapshot()
        snapshot.insertItems([ExerciseRow.circuit(newCircuit)], afterItem: item)
        snapshot.deleteItems([item])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    func updateAMRAP(_ newAmrap: AMRAPModel) {
        guard let item = dataDource.itemIdentifier(for: IndexPath(item: newAmrap.workoutPosition, section: 0)) else {return}
        var snapshot = dataDource.snapshot()
        snapshot.insertItems([ExerciseRow.amrap(newAmrap)], afterItem: item)
        snapshot.deleteItems([item])
        dataDource.apply(snapshot, animatingDifferences: false)
    }
    func updateEMOM(_ newEmom: EMOMModel) {
        guard let item = dataDource.itemIdentifier(for: IndexPath(item: newEmom.workoutPosition, section: 0)) else {return}
        var snapshot = dataDource.snapshot()
        snapshot.insertItems([ExerciseRow.emom(newEmom)], afterItem: item)
        snapshot.deleteItems([item])
        dataDource.apply(snapshot, animatingDifferences: false)
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
        case .amrap(let amrapModel):
            amrapSelected.send(amrapModel)
        case .circuit(let circuitModel):
            circuitSelected.send(circuitModel)
        case .emom(let emomModel):
            emomSelected.send(emomModel)
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



