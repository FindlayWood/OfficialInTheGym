//
//  SavedWorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutDisplayViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: SavedWorkoutCoordinator?
    
    var display = WorkoutDisplayView()
    
    var viewModel = SavedWorkoutDisplayViewModel()
    
    var dataSource: WorkoutExerciseCollectionDataSource!
    
    var childVC = WorkoutChildViewController()
    
    var bottomViewChildVC = SavedWorkoutBottomChildViewController()
    
    var subscriptions = Set<AnyCancellable>()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initNavBarButton()
        viewModel.addAView()
//        setupSubscriptions()
        initDataSource()
        addBottomChildVC()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.savedWorkout.title
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        view.insertSubview(childVC.view, belowSubview: bottomViewChildVC.view)
//        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
//        initDataSource()
    }
    func addBottomChildVC() {
        bottomViewChildVC.viewModel.savedWorkoutModel = viewModel.savedWorkout
        addChild(bottomViewChildVC)
        view.addSubview(bottomViewChildVC.view)
        bottomViewChildVC.view.frame = bottomViewChildVC.viewModel.normalFrame
        bottomViewChildVC.didMove(toParent: self)
        
        bottomViewChildVC.framePublisher
            .sink { [weak self] in self?.bottomViewChildVC.view.frame = $0 }
            .store(in: &subscriptions)
        
        bottomViewChildVC.snapPublisher
            .sink { [weak self] in self?.snapBottomView(to: $0)}
            .store(in: &subscriptions)
        
    }
    // MARK: - Nav Bar Button
    func initNavBarButton() {
        let barButton = UIBarButtonItem(title: "Options", style: .done, target: self, action: #selector(showOptions))
        navigationItem.rightBarButtonItem = barButton
    }
    // MARK: - Data Source
    func initDataSource() {
        childVC.dataSource.updateTable(with: viewModel.exercises)
        
        childVC.dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.coordinator?.showDescriptions($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.amrapSelected
            .sink { [weak self] in self?.coordinator?.showAMRAP($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.circuitSelected
            .sink { [weak self] in self?.coordinator?.showCircuit($0)}
            .store(in: &subscriptions)
        
        childVC.dataSource.emomSelected
            .sink { [weak self] in self?.coordinator?.showEMOM($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {

        dataSource.exerciseButtonTapped
            .sink { [weak self] in self?.coordinator?.showDescriptions($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    @objc func showOptions() {
        coordinator?.showOptions(for: viewModel.savedWorkout)
    }
    
    func snapBottomView(to newFrame: CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.bottomViewChildVC.view.frame = newFrame
        }
    }

    // MARK: - RPE
    func rpe(index: IndexPath) {
        showRPEAlert(for: index) { [weak self] index, score in
            guard let self = self else {return}
            guard let cell = self.display.exerciseCollection.cellForItem(at: index) else {return}
            cell.flash(with: score)
            self.viewModel.updateRPE(at: index, to: score)
        }
    }

}
