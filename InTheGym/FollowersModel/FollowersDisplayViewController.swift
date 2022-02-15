//
//  FollwersDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class FollowersDisplayViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var adapter : FollowersAdapter!
    
    var followers:Bool!
    var DBRef : DatabaseReference!
    
    lazy var viewModel: FollowersViewModel = {
        return FollowersViewModel(apiService: DBRef, followersBool: followers)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DBRef = Database.database().reference()
        adapter = FollowersAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.register(UINib(nibName: "FollowersDisplayTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowersDisplayTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        if followers{
            navigationItem.title = "Followers"
        }else{
            navigationItem.title = "Following"
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
    
    func moveToPublicProfile(with user:Users){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let publicProfile = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        publicProfile.viewModel.user = user
        self.navigationController?.pushViewController(publicProfile, animated: true)
    }
    

}

extension FollowersDisplayViewController: FollowersDisplayProtocol{
    func getData(at: IndexPath) -> Users {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let user = viewModel.getData(at: at)
        moveToPublicProfile(with: user)
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    
}
