//
//  DisplayNotificationsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class DisplayNotificationsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: NotificationsCoordinator?
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var tableview:UITableView!

    var adapter : DisplayNotificationsAdapter!
    
    var DBRef : DatabaseReference!
    
    lazy var viewModel: DisplayNotificationsViewModel = {
        return DisplayNotificationsViewModel(apiService: DBRef)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DBRef = Database.database().reference()
        adapter = DisplayNotificationsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.emptyDataSetDelegate = adapter
        tableview.emptyDataSetSource = adapter
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        
        //removeTabIcon()
        //initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Notifications"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent{
            viewModel.removeObservers()
        }
    }
    
    func initViewModel(){
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
    
    func moveToProfile(with user: Users){
        coordinator?.showUser(user: user)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let profileView = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
//        profileView.user = user
//        navigationController?.pushViewController(profileView, animated: true)
    }
    

}

extension DisplayNotificationsViewController: DisplayNotificationsProtocol{
    
    func getData(at: IndexPath) -> NotificationTableViewModel {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {


    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    
}

