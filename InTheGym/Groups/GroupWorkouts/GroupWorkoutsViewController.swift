//
//  GroupWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class GroupWorkoutsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: GroupWorkoutsCoordinator?
    
    var viewModel = GroupWorkoutsViewModel()
    
    var childVC = SavedWorkoutsChildViewController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColour
//        initViewModel()
        initNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
        initDataSource()
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewWorkout))
        navigationItem.rightBarButtonItems = [barButton]
    }
    
    // MARK: - Data Source
    func initDataSource() {
        
        childVC.dataSource.workoutSelected
            .sink {[weak self] in  self?.coordinator?.showSavedWorkout($0)}
            .store(in: &subscriptions)
        
        initViewModel()
    }
    
    // MARK: - View Model
    func initViewModel() {

        viewModel.$groupWorkouts
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchWorkouts()
    }
    
}

// MARK: - Actions
private extension GroupWorkoutsViewController {
    @objc func addNewWorkout() {
        coordinator?.showSavedWorkoutPicker(completion: { [weak self] newSavedWorkout in
            self?.viewModel.addNewSavedWorkout(newSavedWorkout)
        })
    }
}
