//
//  DiscoverPageDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverPageDataSource: NSObject {
    
    // MARK: - Publisher
    var itemSelected = PassthroughSubject<DiscoverPageItems,Never>()
    var selectedClip = PassthroughSubject<SelectedClip,Never>()
    var moreSelected = PassthroughSubject<DiscoverPageItems,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    var actionSubscriptions = [IndexPath: AnyCancellable]()
    
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<DiscoverPageSections,DiscoverPageItems> {
        let dataSource = UICollectionViewDiffableDataSource<DiscoverPageSections, DiscoverPageItems>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .workout(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedWorkoutCollectionCell.reuseID, for: indexPath) as! SavedWorkoutCollectionCell
                cell.configure(with: model)
                return cell
            case .exercise(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseSelectionCell.reuseIdentifier, for: indexPath) as! ExerciseSelectionCell
                cell.configure(with: model.exerciseName)
                return cell
            case .program(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgramCollectionCell.reuseID, for: indexPath) as! ProgramCollectionCell
                cell.configure(with: model)
                return cell
            case .clip(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseClipsCollectionCell.reuseID, for: indexPath) as! ExerciseClipsCollectionCell
                cell.configure(with: model)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiscoverSectionHeader.reuseIdentifier, for: indexPath) as? DiscoverSectionHeader
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view?.label.text = section.rawValue
            self.actionSubscriptions[indexPath] = view?.moreButtonTapped
                .sink { [weak self] in self?.moreButtonAction(for: indexPath) }
            return view
        }
        
        return dataSource
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<DiscoverPageSections,DiscoverPageItems>()
        snapshot.appendSections([.Workouts,.Exercises,.Clips])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update Workouts
    func updateWorkouts(with models: [SavedWorkoutModel]) {
        let items = models.map { DiscoverPageItems.workout($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .Workouts)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update Exercises
    func updateExercises(with models: [DiscoverExerciseModel]) {
        let items = models.map { DiscoverPageItems.exercise($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .Exercises)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update Clips
    func updateClips(with models: [ClipModel]) {
        let items = models.map { DiscoverPageItems.clip($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .Clips)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Update Programs
    func updateProgram(with models: [SavedProgramModel]) {
        let items = models.map { DiscoverPageItems.program($0)}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(items, toSection: .Programs)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    // MARK: - More Button Action
    func moreButtonAction(for index: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: index) else {return}
        moreSelected.send(model)
    }
}

// MARK: - Delegate
extension DiscoverPageDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExerciseClipsCollectionCell {
            let snapshot = cell.thumbnailImageView.snapshotView(afterScreenUpdates: false)
            self.selectedClip.send(SelectedClip(selectedCell: cell, snapshot: snapshot))
        }
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        itemSelected.send(item)
    }
}
