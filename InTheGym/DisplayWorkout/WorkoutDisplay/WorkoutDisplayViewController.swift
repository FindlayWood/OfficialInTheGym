//
//  WorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDisplayViewController: UIViewController, CustomAnimatingClipFromVC, AnimatingSingleSet {
    
    // MARK: - Coordinator
    weak var coordinator: WorkoutDisplayCoordinator?
    
    // MARK: - Properties
    var display = WorkoutDisplayView()
    
    var viewModel = WorkoutDisplayViewModel()
    
    var dataSource: WorkoutExerciseCollectionDataSource!
    
    var clipDataSource: ClipCollectionDataSource!
    
    var childVC = WorkoutChildViewController()
    
    var bottomViewChildVC = WorkoutBottomChildViewController()
    
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Clip Animation
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?
    
    // MARK: - Set Animation
    var selectedSetCell: MainWorkoutCollectionCell?
    var selectedSetCellImageViewSnapshot: UIView?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        view.backgroundColor = .lightColour
        initDataSource()
        initViewModel()
        initBottomViewChildVC()
        initNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workout.title
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleClipCollection(showing: true, clips: viewModel.getClips())
    }
    // MARK: - Add Child
    func addChildVC() {
        addChild(childVC)
        view.insertSubview(childVC.view, belowSubview: bottomViewChildVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
    }
    // MARK: - Bottom Child VC
    func initBottomViewChildVC() {
        if viewModel.showBottomView() {
            bottomViewChildVC.viewModel.workoutModel = viewModel.workout
            addChild(bottomViewChildVC)
            view.addSubview(bottomViewChildVC.view)
            bottomViewChildVC.view.frame = bottomViewChildVC.viewModel.beginningFrame
            bottomViewChildVC.didMove(toParent: self)
            
            bottomViewChildVC.framePublisher
                .sink { [weak self] in self?.animateBottomFrame(to: $0)}
                .store(in: &subscriptions)
            
            bottomViewChildVC.startWorkoutPublisher
                .sink { [weak self] in self?.startWorkout()}
                .store(in: &subscriptions)
        }
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completed(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        childVC.dataSource.isUserInteractionEnabled = viewModel.isInteractionEnabled()
        childVC.dataSource.updateTable(with: viewModel.exercises)
        
        childVC.clipDataSource.updateTable(with: viewModel.getClips())
        
        childVC.dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.showDiscovery($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.circuitSelected
            .sink { [weak self] in self?.circuitSelected($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.amrapSelected
            .sink { [weak self] in self?.amrapSelected($0) }
            .store(in: &subscriptions)
        
        childVC.dataSource.rpeButtonTapped
            .sink { [weak self] in self?.rpe(index: $0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.completeButtonTapped
            .sink { [weak self] in self?.viewModel.completeSet(at: $0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.clipButtonTapped
            .sink { [weak self] in self?.clipButton(at: $0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.showClipPublisher
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        
        childVC.dataSource.noteButtonTapped
            .sink { _ in print("note tapped") }
            .store(in: &subscriptions)
        
        childVC.dataSource.clipButtonTapped
            .sink { [weak self] exercise in
                guard let self = self else {return}
                self.coordinator?.addClip(for: exercise, self.viewModel.workout, on: self.viewModel)
            }
            .store(in: &subscriptions)
        
        childVC.dataSource.setSelected
            .sink { [weak self] (setCellModel, exerciseModel) in
                self?.selectedSetCell = setCellModel.cell
                self?.selectedSetCellImageViewSnapshot = setCellModel.snapshot
                self?.showSingleSet(setCellModel.setModel, exerciseModel: exerciseModel)
            }
            .store(in: &subscriptions)

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
    func initClipDataSource() {
        clipDataSource = .init(collectionView: display.clipCollection)
        clipDataSource.updateTable(with: viewModel.getClips())
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.initSubscriptions()
        
        viewModel.addedClipPublisher
            .sink { [weak self] in self?.clipDataSource.updateTable(with: [$0]) }
            .store(in: &subscriptions)
        
        viewModel.updatedExercise
            .sink { [weak self] in self?.childVC.dataSource.update(for: $0)}
            .store(in: &subscriptions)
        
        viewModel.editedExercise
            .sink { [weak self] in self?.childVC.dataSource.update(for: $0)}
            .store(in: &subscriptions)
        
        viewModel.editAction
            .sink { [weak self] in self?.editSet($0)}
            .store(in: &subscriptions)
        
        viewModel.updatedCircuit
            .sink { [weak self] in self?.childVC.dataSource.updateCircuit($0)}
            .store(in: &subscriptions)
        viewModel.updatedAMRAP
            .sink { [weak self] in self?.childVC.dataSource.updateAMRAP($0)}
            .store(in: &subscriptions)
    }
    // MARK: - RPE
    func rpe(index: IndexPath) {
        showRPEAlert(for: index) { [weak self] index, score in
            guard let self = self else {return}
            guard let cell = self.childVC.display.exerciseCollection.cellForItem(at: index) else {return}
            cell.flash(with: score) {
                self.viewModel.updateRPE(at: index, to: score)
            }
        }
    }
}

// MARK: - Actions
extension WorkoutDisplayViewController {
    @objc func completed(_ sender: UIBarButtonItem) {
        viewModel.completed()
        coordinator?.complete(viewModel.workout)
    }
    func toggleClipCollection(showing: Bool, clips: [WorkoutClipModel]) {
        if !clips.isEmpty && showing {
            childVC.display.showClipCollection()
        } else if !showing {
            childVC.display.hideClipCollection()
        }
    }
    func clipButton(at exercise: ExerciseModel) {
        coordinator?.addClip(for: exercise, viewModel.workout, on: viewModel)
    }
    func animateBottomFrame(to newFrame: CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.bottomViewChildVC.view.frame = newFrame
        }
    }
    func startWorkout() {
        bottomViewChildVC.willMove(toParent: nil)
        bottomViewChildVC.view.removeFromSuperview()
        bottomViewChildVC.removeFromParent()
        childVC.dataSource.isUserInteractionEnabled = true
        childVC.display.exerciseCollection.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    func showDiscovery(_ exercise: ExerciseModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: exercise.exercise)
        coordinator?.showDescriptions(discoverModel)
    }
    func clipSelected(_ model: WorkoutClipModel) {
        coordinator?.viewClip(model, fromViewControllerDelegate: self)
    }
    func showSingleSet(_ exerciseSet: ExerciseSet, exerciseModel: ExerciseModel?) {
        viewModel.showExerciseDetail = exerciseModel
        coordinator?.showSingleSet(fromViewControllerDelegate: self, setModel: exerciseSet, editAction: viewModel.editAction, isEditable: viewModel.isEditable)
    }
    func editSet(_ set: ExerciseSet) {
        guard let exercise = viewModel.showExerciseDetail else {return}
        coordinator?.editSet(exerciseModel: exercise, publisher: viewModel.editedExercise, setNumber: set.set)
    }
    func circuitSelected(_ circuit: CircuitModel) {
        coordinator?.showCircuit(circuit, viewModel.workout, viewModel.updatedCircuit)
    }
    func amrapSelected(_ amrap: AMRAPModel) {
        coordinator?.showAMRAP(amrap, viewModel.workout, viewModel.updatedAMRAP)
    }
}
