//
//  WorkoutDiscoveryViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDiscoveryViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: WorkoutDiscoveryCoordinator?
    var display = WorkoutDiscoveryView()
    var viewModel = WorkoutDiscoveryViewModel()
    var commentsVC = WorkoutDiscoveryCommentsViewController()
    var tagsVC = WorkoutDiscoveryTagsViewController()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initSubscriptions()
        initTargets()
        display.workoutView.configure(with: viewModel.savedWorkoutModel)
        commentsVC.viewModel.savedWorkoutModel = viewModel.savedWorkoutModel
        tagsVC.viewModel.savedWorkoutModel = viewModel.savedWorkoutModel
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.savedWorkoutModel.title
        editNavBarColour(to: .darkColour)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.selectedIndex == 0 {
            addToContainer(vc: commentsVC)
        } else {
            addToContainer(vc: tagsVC)
        }
    }
    // MARK: - Targets
    func initTargets() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapActions(_:)))
        display.workoutView.addGestureRecognizer(tap)
    }
    // MARK: - Container
    func addToContainer(vc controller: UIViewController) {
        addChild(controller)
        display.addSubview(controller.view)
        controller.view.frame = display.containerView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
    func removeFromContainer(vc controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
    // MARK: - Subscriptions
    func initSubscriptions() {
        display.segment.selectedIndex
            .sink { [weak self] in self?.segmentChanged(to: $0) }
            .store(in: &subscriptions)
    }
    // MARK: - Switch Segment
    func segmentChanged(to index: Int) {
        viewModel.selectedIndex = index
        if index == 0 {
            removeFromContainer(vc: tagsVC)
            addToContainer(vc: commentsVC)
        } else {
            removeFromContainer(vc: commentsVC)
            addToContainer(vc: tagsVC)
        }
    }
}
// MARK: - Actions
private extension WorkoutDiscoveryViewController {
    @objc func workoutTapActions(_ sender: Any) {
        coordinator?.showSavedWorkout()
    }
}
