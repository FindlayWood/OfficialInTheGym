//
//  DescriptionsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DescriptionsViewController: UIViewController {

    // MARK: - Properties
    var display = DescriptionsView()
    
    var viewModel = DescriptionsViewModel()
    
    var dataSource: DescriptionsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initButtonActions()
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    // MARK: - Button Targets
    func initButtonActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.descriptionModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchModels()
    }
}

// MARK: - Button Actions
private extension DescriptionsViewController {
    @objc func plusButtonPressed(_ sender: UIButton) {
        
    }
}