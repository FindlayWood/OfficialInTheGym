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
    
//    @IBOutlet weak var tableview:UITableView!
//    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
//    var adapter : SavedWorkoutsAdapter!
    
    var viewModel = SavedWorkoutsViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    var dataSource: SavedWorkoutsDataSource!


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscriptions()
//        adapter = SavedWorkoutsAdapter(delegate: self)
//        tableview.delegate = adapter
//        tableview.dataSource = adapter
//        tableview.register(UINib(nibName: "SavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "SavedWorkoutCell")
//        tableview.register(UINib(nibName: "PrivateSavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "PrivateSavedWorkoutCell")
//        tableview.tableFooterView = UIView()
//        tableview.emptyDataSetDelegate = adapter
//        tableview.emptyDataSetSource = adapter
//        if #available(iOS 15.0, *) { tableview.sectionHeaderTopPadding = 0 }
        
        //initUI()
        //initViewModel()
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
//
//    override func viewDidDisappear(_ animated: Bool) {
//        if isMovingFromParent{
//            viewModel.removeObservers()
//        }
//    }
    
    func initUI(){
        navigationItem.title = "Saved Workouts"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
    
//    func initViewModel() {
//
//        // Setup for reloadTableViewClosure
//        viewModel.reloadTableViewClosure = { [weak self] () in
//            DispatchQueue.main.async {
//                self?.tableview.reloadData()
//            }
//        }
//
//        // Setup for updateLoadingStatusClosure
//        viewModel.updateLoadingStatusClosure = { [weak self] () in
//            DispatchQueue.main.async {
//                let isLoading = self?.viewModel.isLoading ?? false
//                if isLoading {
//                    self?.activityIndicator.startAnimating()
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self?.tableview.alpha = 0.0
//                    })
//                } else {
//                    self?.activityIndicator.stopAnimating()
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self?.tableview.alpha = 1.0
//                    })
//                }
//            }
//        }
//
//        viewModel.fetchData()
//    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        viewModel.savedWorkoutss
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.selectedWorkout(at: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchKeys()
    }
    
    func selectedWorkout(at indexPath: IndexPath) {
        
    }
    
    func moveToView(){
        // move to new views
        // move with this workout
//        let workouttomove = viewModel.selectedWorkout!
//        coordinator?.savedWorkoutSelected(workouttomove)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let workoutView = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
//        workoutView.selectedWorkout = workouttomove
//        workoutView.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(workoutView, animated: true)
    }

}
//extension SavedWorkoutsViewController : SavedWorkoutsProtocol{
//    func getData(at: IndexPath) -> savedWorkoutDelegate {
//        return self.viewModel.getData(at: at)
//    }
//
//    func itemSelected(at: IndexPath) {
//        viewModel.selectedWorkout = self.viewModel.getData(at: at)
//        self.moveToView()
//    }
//
//    func retreiveNumberOfItems() -> Int {
//        return 1
//    }
//
//    func retreiveNumberOfSections() -> Int {
//        return viewModel.numberOfItems
//    }
//
//
//}
