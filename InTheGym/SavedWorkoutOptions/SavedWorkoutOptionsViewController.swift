//
//  SavedWorkoutOptionsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutOptionsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: SavedWorkoutCoordinator?
    
    private var display = SavedWorkoutOptionsView()
    
    var viewModel = SavedWorkoutOptionsViewModel()
    
    private var dataSource: OptionsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        setupSubscriptions()
        setupActions()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        display.titleLabel.text = viewModel.savedWorkout.title
        view.addSubview(display)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        viewModel.creatorUser
            .dropFirst()
            .receive(on: RunLoop.main)
            .compactMap{ $0 }
            .sink { [weak self] in self?.dataSource.updateTable(with: [$0]) }
            .store(in: &subscriptions)
        
        viewModel.workoutSaved
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.display.saveButton.isHidden = $0 }
            .store(in: &subscriptions)
        
        dataSource.userSelected
            .sink { [weak self] _ in self?.creatorSelected() }
            .store(in: &subscriptions)
        
        viewModel.fetchCreator()
        viewModel.checkSaved()
    }
    
    // MARK: - Button Actions
    func setupActions() {
        display.statsButton.addTarget(self, action: #selector(statsButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func statsButtonTapped(_ sender: UIButton) {
        coordinator?.showWorkoutStats()
    }
    
    // MARK: -
    func creatorSelected() {
        if let creator = viewModel.getCreator() {
            if creator.uid != FirebaseAuthManager.currentlyLoggedInUser.uid {
                coordinator?.showUser(creator)
            }
        }
    }
}
