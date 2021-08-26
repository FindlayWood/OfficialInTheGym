//
//  RequestsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// request page, for a player viewing requests from a coach

import UIKit
import Firebase
import SCLAlertView
import EmptyDataSet_Swift

class RequestsViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var adapter : RequestsAdapter!
    
    var followers:Bool!
    var DBRef : DatabaseReference!
    
    lazy var viewModel: RequestsViewModel = {
        return RequestsViewModel(apiService: DBRef)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBRef = Database.database().reference()
        adapter = RequestsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.emptyDataSetSource = adapter
        tableview.emptyDataSetDelegate = adapter
        tableview.register(UINib(nibName: "RequestsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestsTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = Constants.lightColour
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        navigationItem.title = "Requests"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            viewModel.removeObserver()
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
        
        viewModel.acceptedRequestClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
                DisplayTopView.displayTopView(with: "Accepted request", on: self!)
            }
        }
        
        viewModel.declineRequestClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
                DisplayTopView.displayTopView(with: "Declined request", on: self!)
            }
        }
        viewModel.fetchData()
    }
    
    func moveToProfile(with user: Users){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileView = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }


}

extension RequestsViewController: RequestsProtocol{
    func getData(at: IndexPath) -> Users {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let user = viewModel.getData(at: at)
        moveToProfile(with: user)
    }
    
    func retreiveNumberOfItems() -> Int {
        return 1
    }
    
    func retreiveNumberOfSections() -> Int {
        return viewModel.numberOfItems
    }
}

extension RequestsViewController: buttonTapsRequestDelegate{
    
    func acceptRequest(from user: Users, on: UITableViewCell) {
        let index = tableview.indexPath(for: on)!
        let alert = SCLAlertView()
        alert.addButton("YES", backgroundColor: .green) {
            self.viewModel.acceptRequest(from: user, at: index)
        }
        alert.showWarning("Accept Request", subTitle: "Are you sure you want to accept a request from \(user.username).", closeButtonTitle: "NO")
    }
    
    func declineRequest(from user: Users, on: UITableViewCell) {
        let index = tableview.indexPath(for: on)!
        let alert = SCLAlertView()
        alert.addButton("YES", backgroundColor: .green) {
            self.viewModel.declinedRequest(from: user, at: index)
        }
        alert.showWarning("Decline Request", subTitle: "Are you sure you want to decline a request from \(user.username).", closeButtonTitle: "NO")
    }
    
    func userTapped(on user: Users) {
        moveToProfile(with: user)
    }
    
    
}
