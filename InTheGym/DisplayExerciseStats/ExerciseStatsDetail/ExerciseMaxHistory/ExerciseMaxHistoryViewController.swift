//
//  ExerciseMaxHistoryViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseMaxHistoryViewController: UIViewController {
    
    // MARK: - Properties
    var display = ExerciseMaxHistoryView()
    var viewModel = ExerciseMaxHistoryViewModel()
    var dataSource: ExerciseMaxHistoryDataSource!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$chartDataPublisher
            .compactMap { $0 }
            .sink { [weak self] in self?.display.lineChart.data = $0 }
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$models
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadData()
    }
}
// MARK: - Actions
extension ExerciseMaxHistoryViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
