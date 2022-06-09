//
//  WorkoutDiscoveryTagsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDiscoveryTagsViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: WorkoutDiscoveryCoordinator?
    var display = ExerciseTagsView()
    var viewModel = WorkoutDiscoveryTagsViewModel()
    var dataSource: ExerciseTagDataSource!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTargets()
        initDataSource()
        initViewModel()
    }
    // MARK: - Targets
    func initTargets() {
        display.plusButton.isHidden = !viewModel.showPlusButton
        display.plusButton.addTarget(self, action: #selector(addTagButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$currentTags
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadTags()
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension WorkoutDiscoveryTagsViewController {
    @objc func addTagButtonAction(_ sender: UIButton) {
        let navigationModel = AddWorkoutTagsNavigationModel(
            currentTags: viewModel.currentTags,
            addedNewTagPublisher: viewModel.addNewTagPublisher)
        coordinator?.addNewTag(navigationModel)
    }
}
