//
//  DiscoverPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class DiscoverPageViewController: UIViewController, Storyboarded {
    
    var coordinator: DiscoverFlow?
    
    @IBOutlet weak var collection:UICollectionView!
    @IBOutlet weak var ActivityIndicator:UIActivityIndicatorView!
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var adapter : DiscoverPageAdapter!
    
    var refreshControl : UIRefreshControl!
    
    lazy var viewModel: DiscoverPageViewModel = {
        return DiscoverPageViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstMessage()
        
        adapter = DiscoverPageAdapter(delegate: self)
        collection.delegate = adapter
        collection.dataSource = adapter
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        //layout.itemSize = CGSize(width: width/2-10, height: width/3)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collection.collectionViewLayout = layout
        
        view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.frame
        activityIndicator.startAnimating()
        activityIndicator.color = Constants.darkColour
        self.collection.alpha = 0.0
        
        initRefreshControl()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collection.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        viewModel.fetchWODKey()
        viewModel.fetchWorkoutKeys()
    }
    
    func initViewModel(){
        
        viewModel.updatewodLoadinsStatusClosure = { [unowned self] () in
            let isWODLoading = self.viewModel.isWODLoading
            if isWODLoading {
                self.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.collection.alpha = 0.0
                }
            } else if !self.viewModel.isWorkoutsLoading {
                self.ActivityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.collection.alpha = 1.0
                }
                self.collection.refreshControl?.endRefreshing()
            }
        }
        
        viewModel.updateWorkoutsLoadingStatusClosure = { [unowned self] () in
            let isLoading = self.viewModel.isWorkoutsLoading
            if isLoading {
                self.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.collection.alpha = 0.0
                }
            } else if !self.viewModel.isWODLoading {
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.collection.alpha = 1.0
                }
                self.collection.refreshControl?.endRefreshing()
            }
        }
        
        viewModel.wodLoadedClosure = { [unowned self] () in
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
        
        viewModel.tableViewReloadClosure = { [unowned self] () in
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
        
        viewModel.fetchWODKey()
        viewModel.fetchWorkoutKeys()
        
    }
    
}

//MARK: - Actions
extension DiscoverPageViewController {
    @IBAction func searchTapped(_ sender: UIButton) {
        coordinator?.search()
    }
}


//MARK: - Protocol Methods
extension DiscoverPageViewController : DiscoverPageProtocol {
    func getWorkout(at indexPath: IndexPath) -> discoverWorkout {
        return viewModel.getWorkout(at: indexPath)
    }
    
    func getWOD() -> discoverWorkout {
        return viewModel.getWOD()
    }
    
    func retreiveNumberOfWorkouts() -> Int {
        return viewModel.numberOfWorkouts
    }
    
    func retrieveWOD() -> Bool {
        return viewModel.wodLoaded
    }
    
    func workoutSelected(at indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let displayWorkoutVC = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        var workout : discoverWorkout!
        if indexPath.section == 0 {
            workout = viewModel.getWOD()
            coordinator?.wodSelected(workout: workout)
//            displayWorkoutVC.selectedWorkout = workout
//            displayWorkoutVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(displayWorkoutVC, animated: true)
        } else {
            workout = viewModel.getWorkout(at: indexPath)
            coordinator?.workoutSelected(workout: workout)
//            displayWorkoutVC.selectedWorkout = workout
//            displayWorkoutVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(displayWorkoutVC, animated: true)
        }
        
    }
    
    
}


//MARK: - First Launch Message
extension DiscoverPageViewController {
    func showFirstMessage() {
        if UIApplication.isFirstDiscoverLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("DISCOVER!", subTitle: FirstTimeMessages.discoverMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
