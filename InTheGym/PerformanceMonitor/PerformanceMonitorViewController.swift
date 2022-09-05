//
//  PerformanceMonitorViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PerformanceMonitorViewController: UIViewController {
    // MARK: - Properties
    var display = PerformanceMonitorView()
    var viewModel = PerformanceMonitorViewModel()
    var introVC = PerformanceIntroViewController()
    var workloadChildVC = WorkloadChildViewController()
    var optimalRatioVC = OptimalWorkloadRatioViewController()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        initDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Child VC
    func addSubViews() {
        workloadChildVC.viewModel.user = viewModel.user
        optimalRatioVC.viewModel.user = viewModel.user
//        addToStack(introVC)
        addToStack(workloadChildVC)
        addToStack(optimalRatioVC)
    }
    func addToStack(_ viewController: UIViewController) {
        addChild(viewController)
        display.stack.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    // MARK: - Display
    func initDisplay() {
        if viewModel.user != UserDefaults.currentUser {
            workloadChildVC.display.addButton.isHidden = true
        }
    }
}
