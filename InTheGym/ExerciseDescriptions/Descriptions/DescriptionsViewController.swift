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
        print("descriptions ----------------- ")
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
        viewModel.$descriptionModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        viewModel.$eliteStampCount
            .sink { [weak self] in self?.display.exerciseStampsView.eliteCountLabel.text = $0.description }
            .store(in: &subscriptions)
        viewModel.$verifiedStampCount
            .sink { [weak self] in self?.display.exerciseStampsView.verifiedCountLabel.text = $0.description }
            .store(in: &subscriptions)

        viewModel.fetchModels()
        viewModel.loadRating()
        viewModel.initSubscriptions()
        viewModel.loadStamps()
    }
}
// MARK: - Button Actions
private extension DescriptionsViewController {
    @objc func plusButtonPressed(_ sender: UIButton) {
        coordinator?.addNewDescription(publisher: viewModel.newCommentListener)
    }
    @objc func addRatingButtonAction(_ sender: UIButton) {
        let vc = ExerciseRatingViewController()
        vc.viewModel.addedRatingPublisher = viewModel.addedRatingPublisher
        vc.viewModel.addedStampPublisher = viewModel.addedStampPublisher
        vc.viewModel.currentRating = viewModel.rating
        navigationController?.present(vc, animated: true)
    }
}
