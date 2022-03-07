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
    weak var coordinator: PlayerDetailCoordinator?
    
    var display = PlayerDetailView()
    
    var viewModel = PlayerDetailViewModel()
    
    var scoreChildVC = ScoresPieChartChildViewController()
    
    var workloadChildVC = WorkloadChildViewController()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        display.configure(with: viewModel.user)
        initTargets()
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
    
    // MARK: - Targets
    func initTargets() {
        display.addWorkoutButton.addTarget(self, action: #selector(addWorkout(_:)), for: .touchUpInside)
        display.viewWorkoutsButton.addTarget(self, action: #selector(viewWorkouts(_:)), for: .touchUpInside)
        display.profileImageView.addTarget(self, action: #selector(showPublicProfile(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func addWorkout(_ sender: UIButton) {
        coordinator?.addWorkout()
    }
    
    @objc func viewWorkouts(_ sender: UIButton) {
        coordinator?.viewWorkouts()
    }
    @objc func showPublicProfile(_ sender: UIButton) {
        coordinator?.showPublicProfile()
    }
}
