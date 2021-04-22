//
//  MyGroupsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class MyGroupsViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var tableview:UITableView!
    
    
    var adapter:MyGroupsAdapter!
    
    lazy var viewModel:MyGroupViewModel = {
        return MyGroupViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = MyGroupsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.emptyDataSetSource = adapter
        tableview.emptyDataSetDelegate = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.register(UINib(nibName: "MyGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGroupTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = Constants.lightColour

        initUI()
        //initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            viewModel.removeObservers()
        }
    }
    
    func initUI(){
        self.navigationItem.title = "My Groups"
        if ViewController.admin {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGroup(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    
    func initViewModel(){
        
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            let isLoading = self?.viewModel.isLoading ?? false
            if isLoading{
                self?.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    self?.tableview.alpha = 0.0
                }
            } else {
                self?.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self?.tableview.alpha = 1.0
                }
            }
        }
        
        viewModel.myGroupsLoaded = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        viewModel.fetchData()
        
    }
    
    @IBAction func addNewGroup(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddNewGroupViewController") as! AddNewGroupViewController
        addVC.delegate = self
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    


}

extension MyGroupsViewController: MyGroupsProtocol {
    
    func getGroup(at indexPath: IndexPath) -> groupModel {
        return viewModel.getGroup(at: indexPath)
    }
    
    func groupSelected(at indexPath: IndexPath) {
        // go to group page
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let groupPage = storyboard.instantiateViewController(withIdentifier: "GroupPageViewController") as! GroupPageViewController
        groupPage.group = viewModel.getGroup(at: indexPath)
        self.navigationController?.pushViewController(groupPage, animated: true)
    }
    
    func retreiveNumberOfGroups() -> Int {
        return viewModel.numberOfGroups
    }
    
    func addedNewGroup() {
        viewModel.fetchData()
    }
    
    
}
