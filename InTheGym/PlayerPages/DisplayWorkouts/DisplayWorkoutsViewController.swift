//
//  DisplayWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DisplayingWorkoutsViewController: UIViewController {
    
    // MARK: - Coordinator
    var coordinator: WorkoutsCoordinator?
    
    // MARK: - Display Property
    var display = DisplayingWorkoutsView()
    
    // MARK: - ViewModel
    var viewModel = DisplayingWorkoutsViewModel()
    
    // MARK: - Data Source
    private var dataSource: WorkoutsCollectionDataSource!
    
    // MARK: - Subscriptions
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscribers()
        buttonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Data Source Initializer
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - Button Actions
    func buttonActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        display.programButton.addTarget(self, action: #selector(programButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Subscribers
    func setupSubscribers() {
        viewModel.workouts
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.workoutSelected($0) }
            .store(in: &subscriptions)
        
        viewModel.fetchWorkouts()
    }
    
    // MARK: - Actions
    func workoutSelected(_ workout: WorkoutModel) {
        if workout.liveWorkout ?? false {
            coordinator?.showLiveWorkout(workout)
        } else {
            coordinator?.show(workout)
        }
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        coordinator?.addNewWorkout(UserDefaults.currentUser)
    }
    @objc func programButtonTapped(_ sender: UIButton) {
        coordinator?.addProgram()
    }
}

