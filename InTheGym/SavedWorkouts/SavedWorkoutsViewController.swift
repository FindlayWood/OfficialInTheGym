//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutsViewController: UIViewController {
    
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
        view.backgroundColor = .systemBackground
        initDataSource()
        setupSubscriptions()
        initNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        display.tableview.backgroundColor = .systemBackground
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Saved Workouts"
    }
    
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        collectionDataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        if navigationController?.viewControllers.first == self {
            let dismissButton = UIBarButtonItem(title: "dismiss", style: .done, target: self, action: #selector(dismissAction))
            navigationItem.leftBarButtonItem = dismissButton
        }
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.loadingAction($0) }
            .store(in: &subscriptions)
        viewModel.savedWorkoutss
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.collectionDataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.listRemoveListener
            .sink { [weak self] in self?.collectionDataSource.removeWorkout($0)}
            .store(in: &subscriptions)
        
        collectionDataSource.workoutSelected
            .sink { [weak self] workout in
                guard let self = self else {return}
                self.coordinator?.savedWorkoutSelected(workout, listener: self.viewModel.listRemoveListener)
            }
            .store(in: &subscriptions)
        
        viewModel.fetchKeys()
    }
    
//    func selectedWorkout(at indexPath: IndexPath) {
//        let workout = viewModel.workoutSelected(at: indexPath)
//        coordinator?.savedWorkoutSelected(workout, listener: <#SavedWorkoutRemoveListener?#>)
//    }
    // MARK: - Actions
    @objc func dismissAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    func loadingAction(_ loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
