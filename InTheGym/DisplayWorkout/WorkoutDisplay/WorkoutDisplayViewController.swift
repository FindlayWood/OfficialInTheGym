//
//  WorkoutDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutDisplayViewController: UIViewController {
    
    // MARK: - Properties
    var display = WorkoutDisplayView()
    
    var viewModel = WorkoutDisplayViewModel()
    
    var dataSource: WorkoutExerciseCollectionDataSource!
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscriptions()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .white)
        navigationItem.title = viewModel.workout.title
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.exerciseCollection)
        dataSource.updateTable(with: viewModel.getAllExercises())
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        dataSource.completeButtonTapped
            .sink { [weak self] in self?.viewModel.completeSet(at: $0) }
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


}
