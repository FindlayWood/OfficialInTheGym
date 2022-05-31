//
//  UsersChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

/// The intended purpose of this VC is to be used as a child VC
/// It will appear in multiple diffetent locarions throughout the application
/// A parent VC can control the actions

class UsersChildViewController: UIViewController {
    
    // MARK: - Publishers
    var userSelected = PassthroughSubject<Users,Never>()
    
    // MARK: - Properties
    var display = UsersChildView()
    
    lazy var dataSource: UsersDataSource = UsersDataSource(tableView: display.tableview)
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDataSource()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        display.tableview.separatorStyle = .none
        display.backgroundColor = .secondarySystemBackground
        view.addSubview(display)
    }
    
    // MARK: - Data Source
    func initDataSource() {
//        dataSource = .init(tableView: display.tableview)
        
        dataSource.userSelected
            .sink { [weak self] in self?.userSelected.send($0)}
            .store(in: &subscriptions)
    }
}
