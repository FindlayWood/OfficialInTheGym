//
//  WorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDisplayViewController: UIViewController {
    
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

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
//        setupSubscriptions()
        initBottomViewChildVC()
        initNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        display.frame = getFullViewableFrame()
//        view.addSubview(display)
        addChildVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workout.title
    }
    
    // MARK: - Add Child
    func addChildVC() {
        addChild(childVC)
        view.insertSubview(childVC.view, belowSubview: bottomViewChildVC.view)
//        view.addSubview(childVC.view)
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
        
        childVC.dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.coordinator?.showDescriptions($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.emomSelected
            .sink { [weak self] model in
                guard let self = self else {return}
                self.coordinator?.showEMOM(model, self.viewModel.workout)}
            .store(in: &subscriptions)
        
        childVC.dataSource.circuitSelected
            .sink { [weak self] model in
                guard let self = self else {return}
                self.coordinator?.showCircuit(model, self.viewModel.workout)}
            .store(in: &subscriptions)
        
        childVC.dataSource.amrapSelected
            .sink { [weak self] model in
                guard let self = self else {return}
                self.coordinator?.showAMRAP(model, self.viewModel.workout)}
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
    }

    func initClipDataSource() {
        clipDataSource = .init(collectionView: display.clipCollection)
        clipDataSource.updateTable(with: viewModel.getClips())
    }
    
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        dataSource.completeButtonTapped
            .sink { [weak self] in self?.viewModel.completeSet(at: $0) }
            .store(in: &subscriptions)
        dataSource.noteButtonTapped
            .sink { index in
                print("note tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.rpeButtonTapped
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.rpe(index: $0) }
            .store(in: &subscriptions)
        dataSource.showClipPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        dataSource.clipButtonTapped
            .sink { [weak self] in self?.clipButton(at: $0) }
            .store(in: &subscriptions)

        
        display.bottomView.readyToStartWorkout
            .sink { [weak self] in
                self?.display.bottomView.removeFromSuperview()
                self?.display.flashView.removeFromSuperview()
                self?.initDataSource()
                self?.initNavBar()
            }
            .store(in: &subscriptions)
        
        viewModel.addedClipPublisher
            .sink { [weak self] in self?.clipDataSource.updateTable(with: [$0]) }
            .store(in: &subscriptions)
        
    }
    // MARK: - RPE
    func rpe(index: IndexPath) {
        showRPEAlert(for: index) { [weak self] index, score in
            guard let self = self else {return}
            guard let cell = self.childVC.display.exerciseCollection.cellForItem(at: index) else {return}
            cell.flash(with: score)
            self.viewModel.updateRPE(at: index, to: score)
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
}
