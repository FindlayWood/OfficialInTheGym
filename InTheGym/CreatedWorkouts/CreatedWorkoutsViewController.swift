//
//  CreatedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreatedWorkoutsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CreatedWorkoutsCoordinator?
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var adapter: CreatedWorkoutsAdapter!
    
    lazy var viewModel: CreatedWorkoutsViewModel = {
        return CreatedWorkoutsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = CreatedWorkoutsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.register(UINib(nibName: "PrivateCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "PrivateCreatedWorkoutCell")
        tableview.register(UINib(nibName: "PublicCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "PublicCreatedWorkoutCell")
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = Constants.lightColour
        
        //initUI()
        //initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        initUI()
    }
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent{
            viewModel.removeObservers()
        }
    }
    
    func initUI(){
        navigationItem.title = "Created Workouts"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func initViewModel() {
        
        // Setup for reloadTableViewClosure
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        // Setup for updateLoadingStatusClosure
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.fetchData()
    }
    
    func moveToView(){
        // move to new views
        // move with this workout
        let workouttomove = viewModel.selectedWorkout!
        coordinator?.showWorkout(workout: workouttomove)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let workoutView = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
//        DisplayWorkoutViewController.selectedWorkout = workouttomove
//        workoutView.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(workoutView, animated: true)
    }

}
extension CreatedWorkoutsViewController : CreatedWorkoutsProtocol{
    func getData(at: IndexPath) -> CreatedWorkoutDelegate {
        return self.viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        viewModel.selectedWorkout = self.viewModel.getData(at: at)
        self.moveToView()
    }
    
    func retreiveNumberOfItems() -> Int {
        return 1
    }
    
    func retreiveNumberOfSections() -> Int {
        return viewModel.numberOfItems
    }
    
    
}
