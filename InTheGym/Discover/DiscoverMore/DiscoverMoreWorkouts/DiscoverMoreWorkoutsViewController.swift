//
//  DiscoverMoreWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverMoreWorkoutsViewController: UIViewController {
    
    weak var coordinator: DiscoverCoordinator?
    
    var childVC = SavedWorkoutsChildViewController()
    
    var viewModel = DiscoverMoreWorkoutsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func loadView() {
        view = childVC.display
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initViewModel()
        initDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    
    func addChildVC() {
        addChild(childVC)
        childVC.didMove(toParent: self)
    }
    
    func initDataSource() {
        
        childVC.dataSource.workoutSelected
            .sink { [weak self] in self?.coordinator?.workoutSelected($0)}
            .store(in: &subscriptions)
    }
    
    func initViewModel() {
        
        viewModel.$savedModels
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.loadWorkouts()
    }

}
