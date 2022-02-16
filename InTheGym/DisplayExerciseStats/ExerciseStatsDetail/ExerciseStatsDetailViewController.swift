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
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        display.configure(with: viewModel.statsModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.statsModel.exerciseName
        editNavBarColour(to: .darkColour)
    }
}
