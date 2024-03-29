//
//  DisplayNotificationsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DisplayNotificationsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: NotificationsCoordinator?
    
    var display = DisplayNotificationsView()
    
    var viewModel = DisplayNotificationsViewModel()
    
    var dataSource: NotificationsDataSource!
    
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
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.notificationSelected
            .sink { [weak self] in self?.viewModel.notificationSelected($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.notificationsPublisher
            .sink { [weak self] in self?.dataSource.update(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.destinationPublisher
            .sink { [weak self] in self?.coordinate(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchNotifications()
        
    }
    
    // MARK: - Actions
    func coordinate(to destination: NotificationDestination) {
        switch destination {
        case .post(let post):
            coordinator?.showPost(post: post)
        case .groupPost(let groupPost):
            coordinator?.showGroupPost(post: groupPost)
        case .user(let users):
            coordinator?.showUser(user: users)
        case .newRequest:
            coordinator?.showRequests()
        case .acceptedRequest(let users):
            coordinator?.showPlayerDetail(player: users)
        case .newWorkout:
            break
        }
    }
}


