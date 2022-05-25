//
//  AddWorkoutSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

class NewWorkoutSelectionViewController: UIViewController {
    
    // MARK: - Coordinator
    var coordinator: WorkoutsFlow?
    
    // MARK: - Properties
    var childContentView: NewWorkoutSelectionView!
    
    var viewModel = NewWorkoutSelectionViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Outlets
    @IBOutlet weak var liveAddButton: UIButton!
    @IBOutlet weak var regularAddButton: UIButton!
    @IBOutlet weak var savedWorkoutButton: UIButton!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
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
    
    // MARK: - Init View Model
    func initViewModel() {
        viewModel.selectedOption
            .sink { [weak self] in self?.optionSelected($0)}
            .store(in: &subscriptions)
    }
    
    func optionSelected(_ option: WorkoutBuilderOptions) {
        switch option {
        case .workout:
            coordinator?.addNewWorkout(UserDefaults.currentUser)
        case .liveWorkout:
            coordinator?.addLiveWorkout()
        case .savedWorkout:
            coordinator?.addSavedWorkout()
        }
    }
    
    // MARK: - Live Action
    @IBAction func liveAddWorkout(_ sender:UIButton){
        coordinator?.addLiveWorkout()
    }
    
    // MARK: - Regular Action
    @IBAction func addWorkout(_ sender:UIButton){
        coordinator?.addNewWorkout(UserDefaults.currentUser)
    }
    
    // MARK: - Saved Action
    @IBAction func savedWorkout(_ sender: UIButton) {
         coordinator?.addSavedWorkout()
    }
}
