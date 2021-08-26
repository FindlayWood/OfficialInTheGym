//
//  GroupWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class GroupWorkoutsViewController: UIViewController {
    
    weak var coordinator: GroupWorkoutsCoordinator?
    
    var display = UITableViewView()
    
    var adapter: GroupWorkoutsAdapter!

    var apiService = FirebaseAPIGroupService.shared
    
    var currentGroup: groupModel!
    
    lazy var viewModel: GroupWorkoutsViewModel = {
        return GroupWorkoutsViewModel(apiService: apiService)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initViewModel()
        view.backgroundColor = .darkColour
        navigationItem.title = "Group Workouts"
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewWorkout))
        navigationItem.rightBarButtonItems = [barButton]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func initViewModel() {
        viewModel.reloadTableViewCallback = { [weak self] in
            DispatchQueue.main.async {
                self?.display.tableview.reloadData()
            }
        }
        viewModel.updateLoadingStatusCallback = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let isLoading = self.viewModel.isLoading
                if isLoading {
                    self.display.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 0.0
                    })
                } else {
                    self.display.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.fetchWorkouts(from: currentGroup.uid)
    }
    
}

// MARK: - Display
extension GroupWorkoutsViewController {
    func initDisplay() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.emptyDataSetSource = adapter
        display.tableview.backgroundColor = .darkColour
        display.tableview.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.cellID)
    }
}

extension GroupWorkoutsViewController: GroupWorkoutsProtocol {
    func getData(at indexPath: IndexPath) -> GroupWorkoutModel {
        return viewModel.getData(at: indexPath)
    }
    
    func numberOfWorkouts() -> Int {
        return viewModel.numberOfWorkouts
    }
    
    func workoutSelected(at indexPath: IndexPath) {
        
    }
}

// MARK: - Actions
private extension GroupWorkoutsViewController {
    @objc func addNewWorkout() {
        coordinator?.addNewWorkout()
    }
}
