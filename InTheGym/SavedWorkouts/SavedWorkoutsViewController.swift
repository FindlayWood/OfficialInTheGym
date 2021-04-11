//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class SavedWorkoutsViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var adapter : SavedWorkoutsAdapter!
    
    var DBRef : DatabaseReference!
    
    lazy var viewModel: SavedWorkoutsViewModel = {
        return SavedWorkoutsViewModel(apiService: DBRef)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBRef = Database.database().reference()
        adapter = SavedWorkoutsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.register(UINib(nibName: "SavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "SavedWorkoutCell")
        tableview.register(UINib(nibName: "PrivateSavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "PrivateSavedWorkoutCell")
        tableview.tableFooterView = UIView()
        tableview.emptyDataSetDelegate = adapter
        tableview.emptyDataSetSource = adapter
        
        initUI()
        initViewModel()
    }
    
    func initUI(){
        navigationItem.title = "Saved Workouts"
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let workoutView = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        workoutView.selectedWorkout = workouttomove
        navigationController?.pushViewController(workoutView, animated: true)
    }

}
extension SavedWorkoutsViewController : SavedWorkoutsProtocol{
    func getData(at: IndexPath) -> savedWorkoutDelegate {
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
