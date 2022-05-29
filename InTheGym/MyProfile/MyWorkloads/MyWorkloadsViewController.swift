//
//  MyWorkloadsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyWorkloadsViewController: UIViewController {
    
    // MARK: - Properties
    var display = MyWorkloadsView()
    
    var viewModel = MyWorkloadsViewModel()
    
    var dataSource: MyWorkloadsDataSource!

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        dataSource.updateTable(with: viewModel.workloadModels)
    }
}
