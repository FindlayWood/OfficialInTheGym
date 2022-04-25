//
//  CoachPlayerWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CoachPlayerWorkoutsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: PlayerDetailCoordinator?
    
    var display = CoachPlayerWorkoutsView()
    
    var viewModel = CoachPlayerWorkoutsViewModel()
    
    private var dataSource: WorkoutsCollectionDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.workoutsPublisher
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.loadWorkouts()
    }
}
