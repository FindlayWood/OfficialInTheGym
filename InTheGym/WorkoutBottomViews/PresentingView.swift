//
//  PresentingView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class PresentingView : UIView {
    
    var groupSelectedClosure:((groupModel)->Void)?
    
    lazy var viewModel : MyGroupViewModel = {
        return MyGroupViewModel()
    }()
    
    var adapter : MyGroupsAdapter!
    
    lazy var activityIndicator : UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(frame: self.frame)
        ai.hidesWhenStopped = true
        ai.style = .whiteLarge
        return ai
    }()
    
    lazy var tableview : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 10
        return tv
    }()
    
    let titleLabel : UILabel = {
        let tl = UILabel()
        tl.text = "Share To Group"
        tl.textColor = .white
        tl.font = UIFont.boldSystemFont(ofSize: 20)
        tl.textAlignment = .center
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let cancelButton : UIButton = {
        let cb = UIButton()
        cb.setTitle("cancel", for: .normal)
        cb.setTitleColor(.white, for: .normal)
        cb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cb.translatesAutoresizingMaskIntoConstraints = false
        return cb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Constants.lightColour
        self.layer.cornerRadius = 10
        initTitleLabel()
        initCancelButton()
        initTableView()
        initViewModel()
        tvLayouts()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initTitleLabel(){
        self.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func initCancelButton(){
        self.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
    }
    
    func initTableView(){
        self.addSubview(tableview)
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
    
    func tvLayouts(){
        tableview.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5).isActive = true
        tableview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        tableview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        tableview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

  //MARK: - Conforming to MyGroupProtocol
extension PresentingView: MyGroupsProtocol {
    func getGroup(at indexPath: IndexPath) -> groupModel {
        return viewModel.getGroup(at: indexPath)
    }
    
    func groupSelected(at indexPath: IndexPath) {
        print("tapped group at \(indexPath.section)")
        let group = viewModel.getGroup(at: indexPath)
        let alert = SCLAlertView()
        alert.showSuccess("Share To Group", subTitle: "Would you like to share this workout to the group \(group.groupTitle ?? "ERROR")?", closeButtonTitle: "ok")
        groupSelectedClosure?(group)
       
    }
    
    func retreiveNumberOfGroups() -> Int {
        return viewModel.numberOfGroups
    }
    
    func addedNewGroup() {
        
    }
    
    
}
