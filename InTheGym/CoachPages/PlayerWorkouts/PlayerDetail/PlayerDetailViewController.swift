//
//  PlayerDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class PlayerDetailViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: PlayerDetailCoordinator?
    var display = PlayerDetailView()
    var viewModel = PlayerDetailViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Subviews
    var infoVC = PlayerInfoDetailSubviewViewController()
    var performanceVC = PlayerPerformanceSubviewViewController()
    var buttonVC = PlayerDetailButtonSubviewViewController()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addSubViews()
        initTargets()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Child VC
    func addSubViews() {
        infoVC.viewModel.user = viewModel.user
        addToStack(infoVC)
        addToStack(performanceVC)
        addToStack(buttonVC)
    }
    func addToStack(_ viewController: UIViewController) {
        addChild(viewController)
        display.stack.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    // MARK: - Targets
    func initTargets() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPublicProfile(_:)))
        infoVC.view.addGestureRecognizer(tap)
        buttonVC.display.viewWorkoutsButton.addTarget(self, action: #selector(viewWorkouts(_:)), for: .touchUpInside)
        buttonVC.display.addWorkoutsButton.addTarget(self, action: #selector(addWorkout(_:)), for: .touchUpInside)
        let performanceTap = UITapGestureRecognizer(target: self, action: #selector(showPerformance(_:)))
        performanceVC.view.addGestureRecognizer(performanceTap)
    }
}
// MARK: - Actions
private extension PlayerDetailViewController {
    @objc func addWorkout(_ sender: UIButton) {
        coordinator?.addWorkout()
    }
    @objc func viewWorkouts(_ sender: UIButton) {
        coordinator?.viewWorkouts()
    }
    @objc func showPublicProfile(_ sender: UIButton) {
        coordinator?.showPublicProfile()
    }
    @objc func showPerformance(_ sender: Any) {
        coordinator?.showPerformance(viewModel.user)
    }
}
