//
//  MyWorkoutStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyWorkoutStatsViewController: UIViewController {
    
    // MARK: - Properties
    var display = MyWorkoutStatsView()
    
    var viewModel = MyWorkoutStatsViewModel()
    
    var scoreChildVC = ScoresPieChartChildViewController()
    
    var workloadChildVC = WorkloadChildViewController()
    
    var lastThreeScoresChildVC = LastThreeScoresViewController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
//    override func loadView() {
//        view = display
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        lastThreeSubscription()
        initViewModel()
//        initTargets()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
        initScoreChildVC()
        inintWorkloadChildVC()
        initLastThreeChildVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initTargets()
    }
    // MARK: - Child VC
    func initScoreChildVC() {
        scoreChildVC.viewModel.user = UserDefaults.currentUser
        addChild(scoreChildVC)
        display.addSubview(scoreChildVC.view)
        scoreChildVC.view.frame = display.scoreContainerView.frame
        scoreChildVC.didMove(toParent: self)
    }
    func inintWorkloadChildVC() {
        workloadChildVC.viewModel.user = UserDefaults.currentUser
        addChild(workloadChildVC)
        display.addSubview(workloadChildVC.view)
        workloadChildVC.view.frame = display.workloadContainerView.frame
        workloadChildVC.didMove(toParent: self)
    }
    func initLastThreeChildVC() {
        addChild(lastThreeScoresChildVC)
        display.addSubview(lastThreeScoresChildVC.view)
        lastThreeScoresChildVC.view.frame = display.lastThreeScoresContainerView.frame
        lastThreeScoresChildVC.didMove(toParent: self)
 
    }
    func lastThreeSubscription() {
        scoreChildVC.viewModel.lastThreePublisher
            .sink { [weak self] in self?.lastThreeScoresChildVC.display.configure(with: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - Targets
    func initTargets() {
        let scoresTap = UITapGestureRecognizer(target: self, action: #selector(workloadTappedAction(_:)))
        let workloadTap = UITapGestureRecognizer(target: self, action: #selector(workloadTappedAction(_:)))
        let lastScoresTap = UITapGestureRecognizer(target: self, action: #selector(workloadTappedAction(_:)))
        workloadChildVC.view.addGestureRecognizer(workloadTap)
        scoreChildVC.view.addGestureRecognizer(scoresTap)
        lastThreeScoresChildVC.view.addGestureRecognizer(lastScoresTap)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$myStatsModel
            .compactMap { $0 }
            .sink { [weak self] in self?.display.configure(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadStats()
    }
}
// MARK: - Actions
extension MyWorkoutStatsViewController {
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    @objc func workloadTappedAction(_ sender: Any) {
        let vc = MyWorkloadsViewController()
        vc.viewModel.workloadModels = workloadChildVC.viewModel.workloadModels
        navigationController?.pushViewController(vc, animated: true)
    }
}
