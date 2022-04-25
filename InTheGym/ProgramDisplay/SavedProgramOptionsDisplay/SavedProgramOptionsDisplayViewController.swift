//
//  SavedProgramOptionsDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedProgramOptionsDisplayViewController: UIViewController {
    
    // MARK: - Publishers


    // MARK: - Properties
    weak var coordinator: SavedProgramDisplayCoordinator?
    
    var display = SavedWorkoutBottomChildView()
    
    var viewModel = SavedProgramOptionsDisplayViewModel()
    
    var optionsChildVC = OptionsChildViewController()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initChildDataSource()
        initViewModel()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        addChildVC()
//    }
    
    // MARK: - Add Child
    func addChildVC() {
        addChild(optionsChildVC)
        view.addSubview(optionsChildVC.view)
        optionsChildVC.view.frame = view.bounds
        optionsChildVC.didMove(toParent: self)
    }
    
    // MARK: - Child Data Source
    func initChildDataSource() {
        optionsChildVC.dataSource.optionSelected
            .sink { [weak self] in self?.viewModel.optionSelected($0)}
            .store(in: &subscriptions)
        
//        optionsChildVC.dataSource.updateTable(with: viewModel.baseOptions)
    }
    
    // MARK: - Init View Model
    func initViewModel() {
        
//        viewModel.$isLoading
//            .sink { [weak self] in self?.optionsChildVC.display.collectionView.isHidden = $0 }
//            .store(in: &subscriptions)
        
        viewModel.$currentOptions
            .compactMap { $0 }
            .sink { [weak self] in self?.optionsChildVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.makedCurrentProgram
            .compactMap { $0 }
            .sink { [weak self] model in
                self?.showTopAlert(with: "Done")
//                self?.coordinator?.optionSelected(.makeCurrentProgram)
            }
            .store(in: &subscriptions)
        
        viewModel.loadOptions()
    }
}
