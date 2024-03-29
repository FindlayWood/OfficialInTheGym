//
//  SavedWorkoutBottomChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

class SavedWorkoutBottomChildViewController: UIViewController {
    
    // MARK: - Publishers
    var framePublisher = PassthroughSubject<CGRect,Never>()
    var snapPublisher = PassthroughSubject<CGRect,Never>()
    var showUserPublisher = PassthroughSubject<Users,Never>()
    var showWorkoutStatsPublisher = PassthroughSubject<Void,Never>()
    var showAssignPublisher = PassthroughSubject<Void,Never>()
    var showWorkoutDiscoveryPublisher = PassthroughSubject<Void,Never>()

    // MARK: - Properties
    var childContentView: SavedWorkoutOptionsBottomSheetView!
    var display = SavedWorkoutBottomChildView()
    var viewModel = SavedWorkoutBottomChildViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addPan()
        initTargets()
        initViewModel()
        addChildView()
    }
    func addChildView() {
        childContentView = .init(viewModel: viewModel, action: { [weak self] optionSelected in
            self?.viewModel.optionSelected(optionSelected)
        })
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: display.topAnchor, constant: Constants.screenSize.height * 0.075),
            childView.view.leadingAnchor.constraint(equalTo: display.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: display.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: display.bottomAnchor)
        ])
    }
    // MARK: - Targets
    func initTargets() {
        display.optionsButton.addTarget(self, action: #selector(optionsButtonAction(_:)), for: .touchUpInside)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.removedSavedWorkoutPublisher
            .sink { [weak self] success in
                if success {
                    self?.displayTopMessage(with: "Removed from Saved Workouts")
                } else {
                    self?.showTopMessage()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.addedWorkoutPublisher
            .sink { [weak self] success in
                if success {
                    self?.displayTopMessage(with: "Added to Workouts.")
                } else {
                    self?.showTopMessage()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.savedWorkoutPublisher
            .sink { [weak self] success in
                if success {
                    self?.displayTopMessage(with: "Added to Saved Workouts.")
                } else {
                    self?.showTopMessage()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.showUserPublisher
            .sink { [weak self] in self?.showUserPublisher.send($0)}
            .store(in: &subscriptions)
        
        viewModel.showWorkoutStatsPublisher
            .sink { [weak self] in self?.showWorkoutStatsPublisher.send(())}
            .store(in: &subscriptions)
        
        viewModel.assignPublisher
            .sink { [weak self] in self?.showAssignPublisher.send(())}
            .store(in: &subscriptions)
        
        viewModel.workoutDiscoveryPublisher
            .sink { [weak self] in self?.showWorkoutDiscoveryPublisher.send(())}
            .store(in: &subscriptions)
        
        viewModel.isSaved()
    }
    
    // MARK: - Actions
    func showTopMessage(_ message: String = "Error. Please try again.") {
        showTopAlert(with: message)
    }
    
    // MARK: - Pan Gesture
    func addPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        display.addGestureRecognizer(pan)
    }
    
    @objc func panGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: display)

        var currentYorigin: CGFloat!

        switch viewModel.bottomViewCurrentState {
        case .normal:
            guard viewModel.originPoint.y + translation.y < Constants.screenSize.height - viewModel.minHeight  else {
                snapToState(.normal)
                return
            }
            guard viewModel.originPoint.y + translation.y > Constants.screenSize.height - viewModel.maxHeight else {
                snapToState(.expanded)
                return
            }

            currentYorigin = viewModel.originPoint.y
            let newframe = CGRect(x: 0, y: viewModel.originPoint.y + translation.y, width: viewModel.screen.width, height: viewModel.screen.height)
            framePublisher.send(newframe)
        case .expanded:
            guard viewModel.expandedOriginPoint.y + translation.y < Constants.screenSize.height - viewModel.minHeight else {
                snapToState(.normal)
                return
            }
            guard viewModel.expandedOriginPoint.y + translation.y > Constants.screenSize.height - viewModel.maxHeight else {
                snapToState(.expanded)
                return
            }
            currentYorigin = viewModel.expandedOriginPoint.y
            let newframe = CGRect(x: 0, y: viewModel.expandedOriginPoint.y + translation.y, width: viewModel.screen.width, height: viewModel.screen.height)
            framePublisher.send(newframe)
        }



        switch sender.state {
        case .ended:
            let difference = (viewModel.expandedHeight - viewModel.normalHeight) / 2
            if currentYorigin + translation.y < Constants.screenSize.height - viewModel.normalHeight - difference {
                snapToState(.expanded)
            } else {
                snapToState(.normal)
            }
        default:
            break
        }
    }
    
    func snapToState(_ state: bottomViewState) {
        switch state {
        case .normal:
            viewModel.bottomViewCurrentState = .normal
            snapPublisher.send(viewModel.normalFrame)
        case .expanded:
            viewModel.bottomViewCurrentState = .expanded
            snapPublisher.send(viewModel.expandedFrame)
        }
    }
    
}
// MARK: - Actions
private extension SavedWorkoutBottomChildViewController {
    @objc func optionsButtonAction(_ sender: UIButton) {
        if viewModel.bottomViewCurrentState == .normal {
            snapToState(.expanded)
        } else {
            snapToState(.normal)
        }
    }
}
