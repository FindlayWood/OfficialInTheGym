//
//  SavedWorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutDisplayViewController: UIViewController, AnimatingSingleSet {
    
    // MARK: - Properties
    weak var coordinator: SavedWorkoutCoordinator?
    
    var display = WorkoutDisplayView()
    
    var viewModel = SavedWorkoutDisplayViewModel()
    
    var dataSource: WorkoutExerciseCollectionDataSource!
    
    var childVC = WorkoutChildViewController()
    
    var bottomViewChildVC = SavedWorkoutBottomChildViewController()
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - Set Animation
    var selectedSetCell: MainWorkoutCollectionCell?
    var selectedSetCellImageViewSnapshot: UIView?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        viewModel.addAView()
        initDataSource()
        addBottomChildVC()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.savedWorkout.title
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        view.insertSubview(childVC.view, belowSubview: bottomViewChildVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
    }
    func addBottomChildVC() {
        bottomViewChildVC.viewModel.savedWorkoutModel = viewModel.savedWorkout
        addChild(bottomViewChildVC)
        view.addSubview(bottomViewChildVC.view)
        bottomViewChildVC.view.frame = bottomViewChildVC.viewModel.normalFrame
        bottomViewChildVC.didMove(toParent: self)
        
        bottomViewChildVC.framePublisher
            .sink { [weak self] in self?.bottomViewChildVC.view.frame = $0 }
            .store(in: &subscriptions)
        
        bottomViewChildVC.snapPublisher
            .sink { [weak self] in self?.snapBottomView(to: $0)}
            .store(in: &subscriptions)
        
        bottomViewChildVC.showUserPublisher
            .sink { [weak self] in self?.coordinator?.showUser($0)}
            .store(in: &subscriptions)
        
        bottomViewChildVC.showWorkoutStatsPublisher
            .sink { [weak self] in self?.coordinator?.showWorkoutStats()}
            .store(in: &subscriptions)
        
        bottomViewChildVC.showAssignPublisher
            .sink { [weak self] _ in
                guard let self = self else {return}
                self.coordinator?.showAssign(self.viewModel.savedWorkout)
            }
            .store(in: &subscriptions)
        
        bottomViewChildVC.showWorkoutDiscoveryPublisher
            .sink { [weak self] in self?.coordinator?.showWorkoutDiscovery()}
            .store(in: &subscriptions)
        
    }
    // MARK: - Data Source
    func initDataSource() {
        childVC.dataSource.updateTable(with: viewModel.exercises)
        
        childVC.dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.showDiscover($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.amrapSelected
            .sink { [weak self] in self?.coordinator?.showAMRAP($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.circuitSelected
            .sink { [weak self] in self?.coordinator?.showCircuit($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.emomSelected
            .sink { [weak self] in self?.coordinator?.showEMOM($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.setSelected
            .sink { [weak self] (setCellModel, exerciseModel) in
                self?.selectedSetCell = setCellModel.cell
                self?.selectedSetCellImageViewSnapshot = setCellModel.snapshot
                self?.showSingleSet(setCellModel.setModel)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {

        dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.showDiscover($0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension SavedWorkoutDisplayViewController {
    func showDiscover(_ exercise: ExerciseModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: exercise.exercise)
        coordinator?.showDescriptions(discoverModel)
    }
    func snapBottomView(to newFrame: CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.bottomViewChildVC.view.frame = newFrame
        }
    }
    func showSingleSet(_ exerciseSet: ExerciseSet) {
        coordinator?.showSingleSet(fromViewControllerDelegate: self, setModel: exerciseSet)
    }
}
