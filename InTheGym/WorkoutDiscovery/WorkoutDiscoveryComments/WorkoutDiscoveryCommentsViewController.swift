//
//  WorkoutDiscoveryCommentsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDiscoveryCommentsViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: DescriptionFlow?
    var display = WorkoutDiscoveryCommentsView()
    var viewModel = WorkoutDiscoveryCommentsViewModel()
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
        display.addRatingButton.addTarget(self, action: #selector(addRatingButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$rating
            .compactMap { $0 }
            .sink { [weak self] in self?.display.setRating(to: $0)}
            .store(in: &subscriptions)
        viewModel.$ratingCount
            .compactMap { $0 }
            .sink { [weak self] in self?.display.setRatingCount(to: $0)}
            .store(in: &subscriptions)
        viewModel.$commentModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchModels()
        viewModel.loadRating()
        viewModel.initSubscriptions()
    }
}
// MARK: - Button Actions
private extension WorkoutDiscoveryCommentsViewController {
    @objc func plusButtonPressed(_ sender: UIButton) {
        coordinator?.addNewDescription(publisher: viewModel.newCommentListener)
    }
    @objc func addRatingButtonAction(_ sender: UIButton) {
        let vc = ExerciseRatingViewController()
        vc.viewModel.addedRatingPublisher = viewModel.addedRatingPublisher
        vc.viewModel.currentRating = viewModel.rating
        navigationController?.present(vc, animated: true)
    }
}
