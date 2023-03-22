//
//  PerformanceIntroViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

class PerformanceIntroViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: PerformanceHomeCoordinator?
    
    // MARK: - Sub Views
    var mainView = PerformanceIntroMainView()
    var matchTrackerView = PerformanceIntroSubview(option: .matchTracker)
    var practiceTrackerView = PerformanceIntroSubview(option: .practiceTracker)
    var workloadView = PerformanceIntroSubview(option: .workload)
    var wellnessView = PerformanceIntroSubview(option: .wellness)
    var trainingStatusView = PerformanceIntroSubview(option: .trainingStatus)
    var verticalJumpView = PerformanceIntroSubview(option: .verticalJump)
    var cmjView = PerformanceIntroSubview(option: .cmj)
    var injuryView = PerformanceIntroSubview(option: .injury)
    
    // MARK: - Properties
    var childContentView: PerformanceCenterView!
    var display = Display()
    var viewModel = PerformanceIntroViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
//    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initViewModel()
        initNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        editNavBarColour(to: .premiumColour)
    }
    // MARK: - NAv Bar
    func initNavBar() {
        navigationItem.title = "Performance Center"
        let barButton = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonAction(_:)))
        navigationItem.leftBarButtonItem = barButton
    }
    // MARK: - Targets
    func initTargets() {
        workloadView.actionButton.addTarget(self, action: #selector(workloadButtonAction(_:)), for: .touchUpInside)
        wellnessView.actionButton.addTarget(self, action: #selector(wellnessButtonAction(_:)), for: .touchUpInside)
        trainingStatusView.actionButton.addTarget(self, action: #selector(trainingStatusButtonAction(_:)), for: .touchUpInside)
        verticalJumpView.actionButton.addTarget(self, action: #selector(verticalJumpButtonAction(_:)), for: .touchUpInside)
        cmjView.actionButton.addTarget(self, action: #selector(cmjButtonAction(_:)), for: .touchUpInside)
        injuryView.actionButton.addTarget(self, action: #selector(injuryTrackerButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        childView.view.backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - Child VC
    func addSubViews() {
        addToStack(mainView)
        addToStack(matchTrackerView)
        addToStack(workloadView)
        addToStack(wellnessView)
        addToStack(trainingStatusView)
        addToStack(verticalJumpView)
        addToStack(cmjView)
        addToStack(injuryView)
    }
    func addToStack(_ viewController: UIView) {
        display.stack.addArrangedSubview(viewController)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.action
            .sink { [weak self] in self?.actionSelected($0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension PerformanceIntroViewController {
    func actionSelected(_ action: PerformanceIntroOptions) {
        switch action {
        case .matchTracker:
            coordinator?.showMatchTracker()
        case .workload:
            coordinator?.showWorkload()
        case .wellness:
            coordinator?.showWellness()
        case .trainingStatus:
            coordinator?.showTrainingStatus()
        case .verticalJump:
            coordinator?.showVerticalJump()
        case .cmj:
            coordinator?.showCMJ()
        case .injury:
            coordinator?.showInjuryTracker()
        case .journal:
            coordinator?.showJournalHome()
        case .practiceTracker:
            coordinator?.showPracticeTracker()
        }
    }
    @objc func dismissButtonAction(_ sender: UIButton) {
        coordinator?.dismiss()
    }
    @objc func workloadButtonAction(_ sender: UIButton) {
        coordinator?.showWorkload()
    }
    @objc func wellnessButtonAction(_ sender: UIButton) {
        coordinator?.showWellness()
    }
    @objc func trainingStatusButtonAction(_ sender: UIButton) {
        coordinator?.showTrainingStatus()
    }
    @objc func verticalJumpButtonAction(_ sender: UIButton) {
        coordinator?.showVerticalJump()
    }
    @objc func cmjButtonAction(_ sender: UIButton) {
        coordinator?.showCMJ()
    }
    @objc func injuryTrackerButtonAction(_ sender: UIButton) {
        coordinator?.showInjuryTracker()
    }
}
