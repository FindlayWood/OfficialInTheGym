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
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDataSource()
        setupSubscribers()
        buttonActions()
        initDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let selectedWorkout = viewModel.selectedWorkout else { return }
        dataSource.reloadModel(selectedWorkout)
        viewModel.selectedWorkout = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    // MARK: - Init Display
    func initDisplay() {
        display.segment.selectedIndex
            .sink { [weak self] in self?.viewModel.switchSegment(to: $0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Data Source Initializer
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView, searchDelegate: self)
    }
    
    // MARK: - Button Actions
    func buttonActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        display.collectionView.refreshControl = refreshControl
    }
    
    // MARK: - Subscribers
    func setupSubscribers() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.$workouts
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.updateListener
            .sink { [weak self] in self?.dataSource.reloadModel($0)}
            .store(in: &subscriptions)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.workoutSelected($0) }
            .store(in: &subscriptions)
        
        dataSource.deleteWorkout
            .sink { [weak self] in self?.viewModel.deleteWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.fetchWorkouts()
        viewModel.initSubscribers()
    }
    
    // MARK: - Actions
    func workoutSelected(_ workout: WorkoutModel) {
        viewModel.selectedWorkout = workout
        if workout.liveWorkout ?? false {
            coordinator?.showLiveWorkout(workout)
        } else {
            coordinator?.show(workout)
        }
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        coordinator?.plusPressed()
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        viewModel.fetchWorkouts()
    }
    
    func setLoading(_ loading: Bool) {
        if !loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.refreshControl.endRefreshing()
            }
        }
    }
}
// MARK: - Search Bar Delegate
extension DisplayingWorkoutsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
