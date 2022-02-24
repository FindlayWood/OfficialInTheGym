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
    }
    
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(addNewProgram(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - Subscribers
    func initSubscribers() {
        display.segmentControl.selectedIndex
            .sink { [weak self] in self?.display.setDisplay(to: $0) }
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
private extension MyProgramsViewController {
    @objc func addNewProgram(_ sender: UIButton) {
        coordinator?.addNewProgram(nil)
    }
}
