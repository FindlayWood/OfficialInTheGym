//
//  RequestsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// request page, for a player viewing requests from a coach

import UIKit
import Combine

class RequestsViewController: UIViewController {
    
    // MARK: - Properties
    var display = RequestsView()
    
    var viewModel = RequestsViewModel()
    
    private var dataSource: RequestsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        display.tableview.backgroundColor = .darkColour
        initDataSource()
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.errorPublisher
            .sink { [weak self] _ in self?.showError() }
            .store(in: &subscriptions)
        
        dataSource.acceptSelected
            .sink { [weak self] in self?.viewModel.removeRequest($0)}
            .store(in: &subscriptions)
        
        dataSource.declineSelected
            .sink { [weak self] in self?.viewModel.removeRequest($0)}
            .store(in: &subscriptions)
        
        dataSource.userSelected
            .sink { [weak self] in self?.userSelected($0)}
            .store(in: &subscriptions)
    }

    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.requestsPublisher
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchRequests()
    }
}

// MARK: - Actions
private extension RequestsViewController {
    func userSelected(_ user: Users) {
        let vc = PublicTimelineViewController()
        vc.viewModel.user = user
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

