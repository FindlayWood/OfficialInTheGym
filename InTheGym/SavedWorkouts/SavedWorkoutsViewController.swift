//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutsViewController: UIViewController, Storyboarded {
    
    // MARK: - Properties
    weak var coordinator: SavedWorkoutsFlow?
    
    var display = SavedWorkoutsView()
    
    var loadingScreen: LoadingScreenViewController!
    
    var viewModel = SavedWorkoutsViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    var dataSource: SavedWorkoutsDataSource!
    var collectionDataSource: SavedWorkoutsCollectionDataSource!


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscriptions()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        display.tableview.backgroundColor = .lightColour
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .white)
        navigationItem.title = "Saved Workouts"
    }
    
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        collectionDataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        viewModel.savedWorkoutss
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.collectionDataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        collectionDataSource.workoutSelected
            .sink { [weak self] in self?.selectedWorkout(at: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchKeys()
    }
    
    func selectedWorkout(at indexPath: IndexPath) {
        let workout = viewModel.workoutSelected(at: indexPath)
        coordinator?.savedWorkoutSelected(workout)
    }
}
