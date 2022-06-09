//
//  DescriptionsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class DescriptionsDataSource: NSObject {
    // MARK: - Publisher
    var exerciseCommentTapped = PassthroughSubject<ExerciseCommentModel,Never>()
    var workoutCommentTapped = PassthroughSubject<WorkoutCommentModel,Never>()
    var userTappedExerciseComment = PassthroughSubject<ExerciseCommentModel,Never>()
    var userTappedWorkoutComment = PassthroughSubject<WorkoutCommentModel,Never>()
    
    // MARK: - Properties
    var tableView: UITableView
    
    private lazy var dataSource = makeDataSource()
    
    private var actionSubscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = makeDataSource()
        self.tableView.delegate = self
//        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,ExerciseAndWorkoutCommentItems> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.cellID, for: indexPath) as! DescriptionTableViewCell
            switch itemIdentifier {
            case .exercise(let model):
                cell.configure(with: model)
                cell.actionPublisher
                    .sink { [weak self] in self?.action($0, at: indexPath)}
                    .store(in: &self.actionSubscriptions)
            case .workout(let model):
                cell.configure(with: model)
                cell.actionPublisher
                    .sink { [weak self] in self?.action($0, at: indexPath)}
                    .store(in: &self.actionSubscriptions)
            }
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseAndWorkoutCommentItems>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ExerciseCommentModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseAndWorkoutCommentItems>()
        let items = models.map { ExerciseAndWorkoutCommentItems.exercise($0)}
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    func updateTable(with models: [WorkoutCommentModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseAndWorkoutCommentItems>()
        let items = models.map { ExerciseAndWorkoutCommentItems.workout($0)}
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Add New
    func addNew(_ model: ExerciseCommentModel) {
        var currentSnapshot = dataSource.snapshot()
        if let firstItem = currentSnapshot.itemIdentifiers.first {
            currentSnapshot.insertItems([ExerciseAndWorkoutCommentItems.exercise(model)], beforeItem: firstItem)
        } else {
            currentSnapshot.appendItems([ExerciseAndWorkoutCommentItems.exercise(model)], toSection: .main)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Reload Row
    func reloadRow(with model: ExerciseCommentModel) {
//        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reloadItems([ExerciseAndWorkoutCommentItems.exercise(model)])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    // MARK: - Action
    func action(_ action: DescriptionAction, at index: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: index) else {return}
        switch item {
        case .exercise(let exerciseCommentModel):
            switch action {
            case .likeButton:
                break
            case .userTapped:
                userTappedExerciseComment.send(exerciseCommentModel)
            }
        case .workout(let workoutCommentModel):
            switch action {
            case .likeButton:
                break
            case .userTapped:
                userTappedWorkoutComment.send(workoutCommentModel)
            }
        }
    }
}
// MARK: - Delegate - Select Row
extension DescriptionsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .exercise(let exerciseCommentModel):
            exerciseCommentTapped.send(exerciseCommentModel)
        case .workout(let workoutCommentModel):
            workoutCommentTapped.send(workoutCommentModel)
        }
    }
}
