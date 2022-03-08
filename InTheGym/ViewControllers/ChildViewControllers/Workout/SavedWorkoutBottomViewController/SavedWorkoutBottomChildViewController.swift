//
//  SavedWorkoutBottomChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutBottomChildViewController: UIViewController {
    
    // MARK: - Publishers
    var framePublisher = PassthroughSubject<CGRect,Never>()
    var snapPublisher = PassthroughSubject<CGRect,Never>()

    // MARK: - Properties
    var display = SavedWorkoutBottomChildView()
    
    var viewModel = SavedWorkoutBottomChildViewModel()
    
    var optionsChildVC = OptionsChildViewController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        display.frame = view.bounds
        view.addSubview(display)
        addPan()
//        addChildVC()
        initViewModel()
        initChildDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    
    // MARK: - Add Child
    func addChildVC() {
        addChild(optionsChildVC)
        display.addSubview(optionsChildVC.view)
        optionsChildVC.view.frame = display.newView.frame
        optionsChildVC.didMove(toParent: self)
    }
    
    func initChildDataSource() {
        optionsChildVC.dataSource.optionSelected
            .sink { [weak self] in self?.viewModel.optionSelected($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.optionsPublisher
            .sink { [weak self] in self?.optionsChildVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.isSaved()
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