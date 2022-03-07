//
//  PlayerDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerDetailViewController: UIViewController {
    
    // MARK: - Properties
    var display = PlayerDetailView()
    
    var viewModel = PlayerDetailViewModel()
    
    var scoreChildVC = ScoresPieChartChildViewController()
    
    var workloadChildVC = WorkloadChildViewController()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        display.configure(with: viewModel.user)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
        initScoreChildVC()
        inintWorkloadChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    
    // MARK: - Child VC
    func initScoreChildVC() {
        scoreChildVC.viewModel.user = viewModel.user
        addChild(scoreChildVC)
        display.addSubview(scoreChildVC.view)
        scoreChildVC.view.frame = display.scoreContainerView.frame
        scoreChildVC.didMove(toParent: self)
    }
    
    func inintWorkloadChildVC() {
        workloadChildVC.viewModel.user = viewModel.user
        addChild(workloadChildVC)
        display.addSubview(workloadChildVC.view)
        workloadChildVC.view.frame = display.workloadContainerView.frame
        workloadChildVC.didMove(toParent: self)
    }
}
