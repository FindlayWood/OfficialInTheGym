//
//  WorkoutCreationOptionsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutCreationOptionsViewController: UIViewController {
    // MARK: - Coordinator
    weak var coordinator: WorkoutCreationOptionsCoordinator?
    // MARK: - Properties
    var display = WorkoutCreationOptionsView()
    var viewModel = WorkoutCreationOptionsViewModel()
    var dataSource: ExerciseTagDataSource!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initTargets()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // MARK: - Display
    func initDisplay() {
        display.configure(with: viewModel.assignTo)
        display.privacyView.configure(with: viewModel.isPrivate)
        display.saveView.configure(with: viewModel.saving)
    }
    // MARK: - Targets
    func initTargets() {
        display.saveView.savingButton.addTarget(self, action: #selector(toggleSaving(_:)), for: .touchUpInside)
        display.privacyView.privacyButton.addTarget(self, action: #selector(togglePrivacy(_:)), for: .touchUpInside)
        display.doneButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        display.addTagButton.addTarget(self, action: #selector(addTagButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        dataSource.updateTable(with: viewModel.currentTags)
    }
    // MARK: - ViewModel
    func initViewModel() {
        viewModel.$currentTags
            .compactMap { $0 }
            .sink { [weak self] tags in
                if tags.isEmpty {
                    self?.display.emptyMessage.isHidden = false
                } else {
                    self?.display.emptyMessage.isHidden = true
                    self?.dataSource.updateTable(with: tags)
                }
            }
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension WorkoutCreationOptionsViewController {
    @objc func toggleSaving(_ sender: UIButton) {
        viewModel.saving.toggle()
        viewModel.toggledSaving?.send(())
        display.saveView.configure(with: viewModel.saving)
    }
    @objc func togglePrivacy(_ sender: UIButton) {
        viewModel.isPrivate.toggle()
        viewModel.toggledPrivacy?.send(())
        display.privacyView.configure(with: viewModel.isPrivate)
    }
    @objc func addTagButtonAction(_ sender: UIButton) {
        let navigationModel = AddWorkoutTagsNavigationModel(
            currentTags: viewModel.currentTags,
            addedNewTagPublisher: viewModel.addNewTagPublisher)
        coordinator?.addNewTag(navigationModel)
    }
    @objc func dismissAction(_ sender: UIButton) {
        coordinator?.dismiss()
    }
}
