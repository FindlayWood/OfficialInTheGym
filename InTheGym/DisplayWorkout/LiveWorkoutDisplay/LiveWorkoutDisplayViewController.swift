//
//  LiveWorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class LiveWorkoutDisplayViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: LiveWorkoutDisplayCoordinator?
    
    var display = LiveWorkoutDisplayView()
    
    var viewModel = LiveWorkoutDisplayViewModel()
    
    var dataSource: LiveWorkoutDataSource!
    
    var clipDataSource: ClipCollectionDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        initClipDataSource()
        setupSubscriptions()
        initNavBar()
        toggleClipCollection(showing: true, clips: viewModel.getClips())
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
    
    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completed(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.exerciseCollection, isUserInteractionEnabled: viewModel.isInteractionEnabled())
        dataSource.updateTable(with: viewModel.getInitialExercises())
    }
    func initClipDataSource() {
        clipDataSource = .init(collectionView: display.clipCollection)
        clipDataSource.updateTable(with: viewModel.getClips())
    }

    // MARK: - Subscriptions
    func setupSubscriptions() {
        dataSource.completeButtonTapped
            .sink { index in
                print("complete button tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.noteButtonTapped
            .sink { index in
                print("note tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.rpeButtonTapped
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.rpe(index: $0)}
            .store(in: &subscriptions)
        dataSource.showClipPublisher
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        dataSource.clipButtonTapped
            .sink { [weak self] in self?.clipButton(at: $0) }
            .store(in: &subscriptions)
                
        dataSource.exerciseButtonTapped
            .sink { index in
                print("exercise tapped \(index)")
            }
            .store(in: &subscriptions)
        dataSource.plusExerciseButtonTapped
            .sink { [weak self] in self?.addExercise() }
            .store(in: &subscriptions)
        dataSource.plusSetButtonTapped
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { [weak self] in self?.addSet(at: $0) }
            .store(in: &subscriptions)
        viewModel.addedExercise
            .sink { [weak self] in self?.dataSource.addExercise($0) }
            .store(in: &subscriptions)
        viewModel.updatedExercise
            .sink { [weak self] in self?.dataSource.update(for: $0) }
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
        coordinator?.addExercise(viewModel, workoutPosition: viewModel.getExerciseCount())
    }
    
    func addSet(at indexPath: IndexPath) {
        let exerciseViewModel = viewModel.getExerciseModel(at: indexPath)
        coordinator?.addSet(exerciseViewModel)
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
}
