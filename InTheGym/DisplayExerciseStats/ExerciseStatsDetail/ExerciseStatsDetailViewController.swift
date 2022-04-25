//
//  ExerciseStatsDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseStatsDetailViewController: UIViewController {
    
    // MARK: - Properties
    var display = ExerciseStatsDetailView()

    var viewModel = ExerciseStatsDetailViewModel()
    
    var dataSource: ExerciseStatsDetailDataSource!
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        display.configure(with: viewModel.statsModel)
//        initDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.statsModel.exerciseName
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView, model: viewModel.statsModel)
    }
}
