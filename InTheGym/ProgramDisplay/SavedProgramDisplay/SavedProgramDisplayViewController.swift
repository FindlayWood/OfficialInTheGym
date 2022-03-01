//
//  SavedProgramDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedProgramDisplayViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: SavedProgramDisplayCoordinator!
    
    var viewModel = SavedProgramDisplayViewModel()
    
    var childVC = ProgramsChildViewController()

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
//        initViewModel()
        initSubscriptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.savedProgramModel.title
    }
    
    func addChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
        initDataSource()
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let navButton = UIBarButtonItem(title: "Options", style: .done, target: self, action: #selector(optionsPressed(_:)))
        navigationItem.rightBarButtonItem = navButton
    }
    
    
    // MARK: - Data Source
    func initDataSource() {
        childVC.weeksDataSource.updateTable(with: viewModel.savedProgramModel.weeks.count, isCreating: false, animated: false)
//        childVC.workoutsDataSource.updateTable(with: viewModel.getWorkoutModels(for: 0))
        
        childVC.weeksDataSource.numberSelected
            .sink { [weak self] in self?.viewModel.weekSelectedPublisher.send($0 - 1)}
            .store(in: &subscriptions)
        
        initViewModel()
    }
    
    func initViewModel() {
        viewModel.weekSelectedPublisher
            .sink { [weak self] week in
                guard let self = self else {return}
                self.childVC.workoutsDataSource.updateTable(with: self.viewModel.getWorkoutModels(for: week))
            }
            .store(in: &subscriptions)
    }
    
    func initSubscriptions() {
        coordinator.optionSelected
            .sink { [weak self] option in
                print(option)
            }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension SavedProgramDisplayViewController {
    @objc func optionsPressed(_ sender: UIBarButtonItem) {
        coordinator?.showOptions(viewModel.options)
    }
}
