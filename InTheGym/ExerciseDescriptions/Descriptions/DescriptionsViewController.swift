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
    // MARK: - Coordinatoe
    weak var coordinator: DescriptionFlow?
    // MARK: - Properties
    var display = DescriptionsView()
    var viewModel = DescriptionsViewModel()
    var dataSource: DescriptionsDataSource!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        display.tableview.backgroundColor = .secondarySystemBackground
        initButtonActions()
        initDataSource()
        initViewModel()
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
        viewModel.$descriptionModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.newDescriptionListener
            .sink { [weak self] in self?.dataSource.addNew($0) }
            .store(in: &subscriptions)
        
        viewModel.fetchModels()
    }
}
// MARK: - Button Actions
private extension DescriptionsViewController {
    @objc func plusButtonPressed(_ sender: UIButton) {
        let descriptionModel = DescriptionModel(exercise: viewModel.exerciseModel.exerciseName, description: "")
        coordinator?.addNewDescription(descriptionModel, publisher: viewModel.newDescriptionListener)
    }
}
