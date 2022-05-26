//
//  ExerciseTagsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseTagsViewController: UIViewController {
    
    // MARK: - Properties
    var display = ExerciseTagsView()
    
    var viewModel = ExerciseTagsViewModel()
    
    var dataSource: ExerciseTagDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDataSource()
        initViewModel()
        initTargets()
    }
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$tagModels
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.loadTags()
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension ExerciseTagsViewController {
    @objc func addButtonAction(_ sender: UIButton) {
        let vc = AddNewTagViewController()
        vc.viewModel.exerciseModel = viewModel.exerciseModel
        vc.viewModel.addNewTagPublisher = viewModel.addedNewTagPublisher
        vc.viewModel.currentTags = viewModel.tagModels
        present(vc, animated: true)
    }
}
