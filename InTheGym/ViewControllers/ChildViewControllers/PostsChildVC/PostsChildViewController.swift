//
//  PostsChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostsChildViewController: UIViewController {
    
    // MARK: - Properties
    var display = PostsChildView()
    
    lazy var dataSource = PostsDataSource(tableView: display.tableview)
    
//    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }


}
