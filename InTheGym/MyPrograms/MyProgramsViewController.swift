//
//  MyProgramsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyProgramsViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: MyProgramsCoordinator?
    
    var display = MyProgramsView()
    
    var viewModel = MyProgramsViewModel()
    
    var dataSource: MyProgramsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initTargets()
        initDataSource()
        initSubscribers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
        if !isMovingToParent {
            viewModel.setSelectedIndex(to: 0)
        }
    }
    
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(addNewProgram(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
//        dataSource.updateTable(with: viewModel.currentProgram.value)
    }
    
    // MARK: - Subscribers
    func initSubscribers() {
        display.segmentControl.selectedIndex
            .sink { [weak self] in self?.viewModel.setSelectedIndex(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.selectedIndex
            .sink { [weak self] in self?.display.setDisplay(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.currentProgram
            .sink { [weak self] models in
                if self?.viewModel.selectedIndex.value == 0 {
                    self?.dataSource.updateTable(with: models)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.savedPrograms
            .sink { [weak self] models in
                if self?.viewModel.selectedIndex.value == 1 {
                    self?.dataSource.updateTable(with: models)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.completedPrograms
            .sink { [weak self] models in
                if self?.viewModel.selectedIndex.value == 2 {
                    self?.dataSource.updateTable(with: models)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.modelsToShow
            .sink { [weak self] type in
                switch type {
                case .program(let models):
                    self?.dataSource.updateTable(with: models)
                case .saved(let models):
                    self?.dataSource.updateTable(with: models)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.fetchSavedPrograms()
//        viewModel.modelsToShow.send(MyProgramsToShow.program(viewModel.currentProgram.value))
    }
}

// MARK: - Actions
private extension MyProgramsViewController {
    @objc func addNewProgram(_ sender: UIButton) {
        coordinator?.addNewProgram(nil)
    }
}
