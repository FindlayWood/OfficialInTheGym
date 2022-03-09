//
//  WorkoutBottomChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutBottomChildViewController: UIViewController {
    
    // MARK: - Publishers
    var framePublisher = PassthroughSubject<CGRect,Never>()
    var startWorkoutPublisher = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var display = WorkoutBottomChildView()
    
    var viewModel = WorkoutBottomChildViewModel()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
    }
    
    // MARK: - Targets
    func addTargets() {
        display.newButton.addTarget(self, action: #selector(beginWorkoutTapped(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func beginWorkoutTapped(_ sender: UIButton) {
        switch viewModel.bottomViewStage {
        case .first:
            framePublisher.send(viewModel.secondFrame)
            viewModel.bottomViewStage = .second
            display.changeStage(to: .second)
        case .second:
            framePublisher.send(viewModel.fullFrame)
            viewModel.bottomViewStage = .third(viewModel.workoutModel.title)
            display.changeStage(to: viewModel.bottomViewStage)
            viewModel.startWorkout()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startWorkoutPublisher.send(())
            }
        case .third(_):
            break
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        framePublisher.send(viewModel.beginningFrame)
        viewModel.bottomViewStage = .first
        display.changeStage(to: .first)
    }
}
