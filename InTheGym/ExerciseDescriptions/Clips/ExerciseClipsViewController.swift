//
//  ExerciseClipsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseClipsViewController: UIViewController {
    
    // MARK: - Properties
    var display = ExerciseClipsView()
    
    var viewModel = ExerciseClipsViewModel()
    
    var dataSource: ExerciseClipsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initButtonActions()
        initDataSource()
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    // MARK: - Button Targets
    func initButtonActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.clipModelPublisher
            .map { models in
                models.filter { !($0.isPrivate) }
            }
            .sink { [weak self] in self?.dataSource.updateCollection(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchClipKeys()
    }
}

// MARK: - Button Actions
extension ExerciseClipsViewController {
    @objc func plusButtonPressed(_ sender: UIButton) {
        let vc = RecordClipViewController()
        vc.viewModel.exerciseModel = viewModel.exerciseModel
        vc.viewModel.addingDelegate = viewModel
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        navigationController?.present(vc, animated: true)
    }
    
}
