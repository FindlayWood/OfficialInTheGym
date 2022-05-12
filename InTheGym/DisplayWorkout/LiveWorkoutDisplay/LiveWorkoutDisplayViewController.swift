//
//  LiveWorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class LiveWorkoutDisplayViewController: UIViewController, CustomAnimatingClipFromVC, AnimatingSingleSet {
    
    // MARK: - Properties
    weak var coordinator: LiveWorkoutDisplayCoordinator?
    
    var display = LiveWorkoutDisplayView()
    
    var viewModel = LiveWorkoutDisplayViewModel()
    
    var dataSource: LiveWorkoutDataSource!
    
    var clipDataSource: ClipCollectionDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Clip Animation
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?
    
    // MARK: - Set Animation
    var selectedSetCell: MainWorkoutCollectionCell?
    var selectedSetCellImageViewSnapshot: UIView?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        initClipDataSource()
        setupSubscriptions()
        initNavBar()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workoutModel.title
        //viewModel.setupExercises()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleClipCollection(showing: true, clips: viewModel.getClips())
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completed(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.addedClipPublisher
            .sink { [weak self] newClip in
                guard let self = self else {return}
                self.clipDataSource.updateTable(with: [newClip])
                self.toggleClipCollection(showing: true, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        
        viewModel.initSubscriptions()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.exerciseCollection, isUserInteractionEnabled: viewModel.isInteractionEnabled())
        dataSource.updateTable(with: viewModel.getInitialExercises())
        
        dataSource.clipButtonTapped
            .sink {[weak self] exercise in
                guard let self = self else {return}
                self.coordinator?.addClip(for: exercise, self.viewModel.workoutModel, on: self.viewModel)
            }
            .store(in: &subscriptions)
    }
    func initClipDataSource() {
        clipDataSource = .init(collectionView: display.clipCollection)
        clipDataSource.updateTable(with: viewModel.getClips())
        
        clipDataSource.clipSelected
            .sink { [weak self] in self?.clipSelected($0)}
            .store(in: &subscriptions)
        
        clipDataSource.selectedCell
            .sink { [weak self] selectedCell in
                self?.selectedCell = selectedCell.selectedCell
                self?.selectedCellImageViewSnapshot = selectedCell.snapshot
            }
            .store(in: &subscriptions)
    }

    // MARK: - Subscriptions
    func setupSubscriptions() {
        
        dataSource.setSelected
            .sink { [weak self] setCellModel in
                self?.selectedSetCell = setCellModel.cell
                self?.selectedSetCellImageViewSnapshot = setCellModel.snapshot
                self?.showSingleSet()
            }
            .store(in: &subscriptions)

        dataSource.noteButtonTapped
            .sink { index in
                print("note tapped at \(index)")
            }
            .store(in: &subscriptions)
        
        dataSource.rpeButtonTapped
            .sink { [weak self] in self?.rpe(index: $0)}
            .store(in: &subscriptions)
        
        dataSource.showClipPublisher
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        
        dataSource.clipButtonTapped
            .sink { [weak self] in self?.clipButton(at: $0) }
            .store(in: &subscriptions)
                
        dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.coordinator?.showDescriptions(for: $0) }
            .store(in: &subscriptions)
        
        dataSource.plusExerciseButtonTapped
            .sink { [weak self] in self?.addExercise() }
            .store(in: &subscriptions)
        
        dataSource.plusSetButtonTapped
            .sink { [weak self] in self?.addSet(at: $0) }
            .store(in: &subscriptions)
        
        viewModel.addedExercise
            .sink { [weak self] in self?.dataSource.addExercise($0) }
            .store(in: &subscriptions)
        
        viewModel.updatedExercise
            .sink { [weak self] in self?.dataSource.update(for: $0)}
            .store(in: &subscriptions)
        
    }
    
    // MARK: - RPE
    func rpe(index: IndexPath) {
        showRPEAlert(for: index) { [weak self] index, score in
            guard let self = self else {return}
            guard let cell = self.display.exerciseCollection.cellForItem(at: index) else {return}
            cell.flash(with: score)
            self.viewModel.updateRPE(at: index, to: score)
        }
    }
}

// MARK: - Actions
extension LiveWorkoutDisplayViewController {
    @objc func completed(_ sender: UIBarButtonItem) {
        viewModel.completed()
        coordinator?.complete(viewModel.workoutModel)
    }
    
    func addExercise() {
        let newExercise = ExerciseModel(workoutPosition: viewModel.getExerciseCount())
        coordinator?.addExercise(newExercise, publisher: viewModel.addedExercise)
    }
    
    func addSet(at indexPath: IndexPath) {
        let exercise = viewModel.getExercise(at: indexPath)
        coordinator?.addSet(exercise, publisher: viewModel.updatedExercise)
    }
    func toggleClipCollection(showing: Bool, clips: [WorkoutClipModel]) {
        if !clips.isEmpty && showing {
            display.showClipCollection()
        } else if !showing {
            display.hideClipCollection()
        }
    }
    func clipButton(at exercise: ExerciseModel) {
        coordinator?.addClip(for: exercise, viewModel.workoutModel, on: viewModel)
    }
    func showDescriptions(for exercise: ExerciseModel) {
        coordinator?.showDescriptions(for: exercise)
//        let vc = ExerciseDescriptionViewController()
//        vc.viewModel.exercise = DiscoverExerciseModel(exerciseName: exercise.exercise)
//        navigationController?.pushViewController(vc, animated: true)
    }
    func clipSelected(_ model: WorkoutClipModel) {
        coordinator?.viewClip(model, fromViewControllerDelegate: self)
    }
    func showSingleSet() {
        coordinator?.showSingleSet(fromViewControllerDelegate: self)
    }
}
