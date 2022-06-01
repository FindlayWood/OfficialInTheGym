//
//  PostCompletedWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

class PostCompletedWorkoutViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: CompletedWorkoutCoordinator?
    
    var childContentView: PostCompletedWorkoutView!
    
    var viewModel = PostCompletedWorkoutViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
             childView.view.topAnchor.constraint(equalTo: view.topAnchor),
             childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }
    
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.postWorkoutSelected
            .sink { [weak self] in self?.postWorkout()}
            .store(in: &subscriptions)
        
        viewModel.dismissSelected
            .sink { [weak self] in self?.coordinator?.dismiss()}
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
private extension PostCompletedWorkoutViewController {
    func postWorkout() {
        coordinator?.postWorkout(viewModel.workoutModel)
    }
}
