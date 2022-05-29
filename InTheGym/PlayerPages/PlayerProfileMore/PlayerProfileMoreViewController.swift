//
//  PlayerProfileMoreViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class PlayerProfileMoreViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: PlayerProfileMoreCoordinator?
    
    var childContentView: PlayerProfileMoreView!
    
    var viewModel = PlayerProfileMoreViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = UserDefaults.currentUser.username
    }


    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.actionPublisher
            .sink { [weak self] in self?.actionHandler($0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension PlayerProfileMoreViewController {
    func actionHandler(_ action: PlayerProfileMoreAction) {
        switch action {
        case .editProfile:
            coordinator?.editProfile()
        case .myCoaches:
            coordinator?.myCoaches()
        case .requests:
            coordinator?.myRequests()
        case .exerciseStats:
            coordinator?.exerciseStats()
        case .workoutStats:
            coordinator?.myWorkoutStats()
        case .measureJump:
            coordinator?.jumpMeasure()
        case .breathWork:
            coordinator?.breathWork()
        case .settings:
            coordinator?.settings()
        }
    }
}
