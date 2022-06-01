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
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        initScoreChildVC()
        inintWorkloadChildVC()
        initLastThreeChildVC()
        lastThreeSubscription()
        initViewModel()
        initTargets()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Child VC
    func initScoreChildVC() {
        scoreChildVC.viewModel.user = UserDefaults.currentUser
        addChild(scoreChildVC)
        display.addSubview(scoreChildVC.view)
        scoreChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreChildVC.view.topAnchor.constraint(equalTo: display.scoreContainerView.topAnchor),
            scoreChildVC.view.leadingAnchor.constraint(equalTo: display.scoreContainerView.leadingAnchor),
            scoreChildVC.view.trailingAnchor.constraint(equalTo: display.scoreContainerView.trailingAnchor),
            scoreChildVC.view.bottomAnchor.constraint(equalTo: display.scoreContainerView.bottomAnchor)
        ])
        scoreChildVC.didMove(toParent: self)
    }
    func inintWorkloadChildVC() {
        workloadChildVC.viewModel.user = UserDefaults.currentUser
        addChild(workloadChildVC)
        display.addSubview(workloadChildVC.view)
        workloadChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            workloadChildVC.view.topAnchor.constraint(equalTo: display.workloadContainerView.topAnchor),
            workloadChildVC.view.leadingAnchor.constraint(equalTo: display.workloadContainerView.leadingAnchor),
            workloadChildVC.view.trailingAnchor.constraint(equalTo: display.workloadContainerView.trailingAnchor),
            workloadChildVC.view.bottomAnchor.constraint(equalTo: display.workloadContainerView.bottomAnchor)
        ])
        workloadChildVC.didMove(toParent: self)
    }
    func initLastThreeChildVC() {
        addChild(lastThreeScoresChildVC)
        display.addSubview(lastThreeScoresChildVC.view)
        lastThreeScoresChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lastThreeScoresChildVC.view.topAnchor.constraint(equalTo: display.lastThreeScoresContainerView.topAnchor),
            lastThreeScoresChildVC.view.leadingAnchor.constraint(equalTo: display.lastThreeScoresContainerView.leadingAnchor),
            lastThreeScoresChildVC.view.trailingAnchor.constraint(equalTo: display.lastThreeScoresContainerView.trailingAnchor),
            lastThreeScoresChildVC.view.bottomAnchor.constraint(equalTo: display.lastThreeScoresContainerView.bottomAnchor)
        ])
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
