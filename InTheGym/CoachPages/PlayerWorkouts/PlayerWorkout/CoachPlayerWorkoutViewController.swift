//
//  CoachPlayerWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CoachPlayerWorkoutViewController: UIViewController, CustomAnimatingClipFromVC, AnimatingSingleSet {
    
    // MARK: - Properties
    weak var coordinator: PlayerDetailCoordinator?
    var childVC = WorkoutChildViewController()
    var viewModel = CoachPlayerWorkoutViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Clip Animation
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?
    // MARK: - Set Animation
    var selectedSetCell: MainWorkoutCollectionCell?
    var selectedSetCellImageViewSnapshot: UIView?
    
    // MARK: - View
    override func loadView() {
        view = childVC.display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        addChildVC()
        initDataSource()
        initClipDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workoutModel.title
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleClipCollection(showing: true, clips: viewModel.getClips())
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        childVC.didMove(toParent: self)
        NSLayoutConstraint.activate([
            childVC.display.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    // MARK: - Data Source
    func initDataSource() {
        childVC.dataSource.updateTable(with: viewModel.getAllExercises())
        
        childVC.dataSource.showClipPublisher
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        childVC.dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.showDiscovery($0)}
            .store(in: &subscriptions)
        childVC.dataSource.setSelected
            .sink { [weak self] (setCellModel, exerciseModel) in
                self?.selectedSetCell = setCellModel.cell
                self?.selectedSetCellImageViewSnapshot = setCellModel.snapshot
                self?.showSingleSet(setCellModel.setModel, exerciseModel: exerciseModel)
            }
            .store(in: &subscriptions)
    }
    // MARK: - Clip Data Source
    func initClipDataSource() {
        childVC.clipDataSource.updateTable(with: viewModel.getClips())
        childVC.clipDataSource.clipSelected
            .sink { [weak self] in self?.clipSelected($0)}
            .store(in: &subscriptions)
        
        childVC.clipDataSource.selectedCell
            .sink { [weak self] selectedCell in
                self?.selectedCell = selectedCell.selectedCell
                self?.selectedCellImageViewSnapshot = selectedCell.snapshot
            }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension CoachPlayerWorkoutViewController {
    func toggleClipCollection(showing: Bool, clips: [WorkoutClipModel]) {
        if !clips.isEmpty && showing {
            childVC.display.showClipCollection()
        } else if !showing {
            childVC.display.hideClipCollection()
        }
    }
    func clipSelected(_ model: WorkoutClipModel) {
        coordinator?.viewClip(model, fromViewControllerDelegate: self)
    }
    func showDiscovery(_ exercise: ExerciseModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: exercise.exercise)
        coordinator?.showDescriptions(discoverModel)
    }
    func showSingleSet(_ exerciseSet: ExerciseSet, exerciseModel: ExerciseModel?) {
        coordinator?.showSingleSet(fromViewControllerDelegate: self, setModel: exerciseSet)
    }
}
