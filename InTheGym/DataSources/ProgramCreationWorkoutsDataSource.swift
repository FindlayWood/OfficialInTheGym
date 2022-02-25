//
//  ProgramCreationWorkoutsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ProgramCreationWorkoutsDataSource: NSObject {
    
    // MARK: - Publisher
    var workoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var plusSelected = PassthroughSubject<Void,Never>()
    var removeItem = PassthroughSubject<Int,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
//        self.initLongPress()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<ProgramCreationWorkoutSections,ProgramCreationWorkoutItems> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .creatingWorkout(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedWorkoutCollectionCell.reuseID, for: indexPath) as! SavedWorkoutCollectionCell
                cell.configure(with: model.savedWorkout)
                return cell
            case .workout(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCollectionViewCell.reuseID, for: indexPath) as! WorkoutCollectionViewCell
                cell.configure(with: model.workoutModel)
                return cell
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID, for: indexPath) as! LiveWorkoutPlusCollectionCell
                self.subscriptions[indexPath] = cell.plusTappedPublisher
                    .sink(receiveValue: { [weak self] in
                        self?.plusSelected.send(())
                    })
                return cell
            }

        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<ProgramCreationWorkoutSections,ProgramCreationWorkoutItems>()
        snapshot.appendSections([.workouts])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setForCreation() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.plus])
        currentSnapshot.appendItems([ProgramCreationWorkoutItems.plus], toSection: .plus)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ProgramCreationWorkoutCellModel]) {
        let items = models.map { ProgramCreationWorkoutItems.creatingWorkout($0) }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .workouts)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    func updateTable(with models: [ProgramWorkoutCellModel]) {
        let items = models.map { ProgramCreationWorkoutItems.workout($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteAllItems()
        currentSnapshot.appendSections([.workouts])
        currentSnapshot.appendItems(items, toSection: .workouts)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Add
    func addWorkout(_ model: ProgramCreationWorkoutCellModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([ProgramCreationWorkoutItems.creatingWorkout(model)], toSection: .workouts)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Remove All
    func removeAll(_ isCreating: Bool) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteAllItems()
        currentSnapshot.appendSections([.workouts])
        if isCreating {
            currentSnapshot.appendSections([.plus])
            currentSnapshot.appendItems([.plus], toSection: .plus)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    // MARK: - Long Press
    func initLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
                switch model {
                case .creatingWorkout(_):
                    self.removeItem(model)
                    self.removeItem.send(indexPath.item)
                case .plus, .workout(_):
                    break
                }
            }
        }
    }
    
    // MARK: - Remove Item
    func removeItem(_ item: ProgramCreationWorkoutItems) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems([item])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension ProgramCreationWorkoutsDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        switch model {
        case .creatingWorkout(let workout):
            self.workoutSelected.send(workout.savedWorkout)
        case .plus:
            self.plusSelected.send(())
        case .workout(_):
            break
        }
    }
}
