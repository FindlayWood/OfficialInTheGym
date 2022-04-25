//
//  CoachPlayerWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CoachPlayerWorkoutViewController: UIViewController {
    
    // MARK: - Properties
    var childVC = WorkoutChildViewController()
    
    var viewModel = CoachPlayerWorkoutViewModel()

    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workoutModel.title
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
        initDataSource()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        childVC.dataSource.updateTable(with: viewModel.getAllExercises())
        
        childVC.dataSource.showClipPublisher
            .sink { [weak self] show in
                guard let self = self else {return}
                self.toggleClipCollection(showing: show, clips: self.viewModel.getClips())
            }
            .store(in: &subscriptions)
        
        // TODO: Need Coordinator
//        childVC.clipDataSource.clipSelected
//            .sink { [weak self] in self?.coordinator?.viewClip($0)}
//            .store(in: &subscriptions)
    }
}

private extension CoachPlayerWorkoutViewController {
    func toggleClipCollection(showing: Bool, clips: [WorkoutClipModel]) {
        if !clips.isEmpty && showing {
            childVC.display.showClipCollection()
        } else if !showing {
            childVC.display.hideClipCollection()
        }
    }
}
