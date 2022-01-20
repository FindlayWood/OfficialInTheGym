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
    
    var subscriptions = Set<AnyCancellable>()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscriptions()
        initNavBarButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.savedWorkout.title
    }
    // MARK: - Nav Bar Button
    func initNavBarButton() {
        let barButton = UIBarButtonItem(title: "Options", style: .done, target: self, action: #selector(showOptions))
        navigationItem.rightBarButtonItem = barButton
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.exerciseCollection, isUserInteractionEnabled: false)
        dataSource.updateTable(with: viewModel.exercises)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        dataSource.completeButtonTapped
            .sink { index in
                print("complete button tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.noteButtonTapped
            .sink { index in
                print("note tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.rpeButtonTapped
            .sink { index in
                print("rpe tapped at \(index)")
            }
            .store(in: &subscriptions)
        dataSource.showClipPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { show in
                print("show clip \(show)")
            }
            .store(in: &subscriptions)
        dataSource.clipButtonTapped
            .sink { index in
                print("clip tapped \(index)")
            }
            .store(in: &subscriptions)
        dataSource.exerciseButtonTapped
            .sink { index in
                print("exercise tapped \(index)")
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    @objc func showOptions() {
        coordinator?.showOptions(for: viewModel.savedWorkout)
    }

}
