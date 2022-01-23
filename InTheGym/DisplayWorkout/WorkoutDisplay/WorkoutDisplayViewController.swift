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
    // MARK: - Coordinator
    weak var coordinator: WorkoutDisplayCoordinator?
    
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
        initNavBar()
//        display.addBottomView()
//        display.bottomView.title = viewModel.workout.title
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
    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completed(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.exerciseCollection, isUserInteractionEnabled: viewModel.isInteractionEnabled())
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
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.rpe(index: $0) }
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
        dataSource.rowSelected
            .sink { [weak self] in self?.selectedRow($0) }
            .store(in: &subscriptions)
        
        display.bottomView.readyToStartWorkout
            .sink { [weak self] in
                self?.display.bottomView.removeFromSuperview()
                self?.display.flashView.removeFromSuperview()
                self?.initDataSource()
                self?.initNavBar()
            }
            .store(in: &subscriptions)
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

// MARK: - Actions
extension WorkoutDisplayViewController {
    @objc func completed(_ sender: UIBarButtonItem) {
        viewModel.completed()
    }
    func selectedRow(_ type: ExerciseRow) {
        switch type {
        case .exercise(let exerciseModel):
            break
        case .circuit(let circuitModel):
            // TODO: - Coordinate to circuit
            print("circuit")
        case .emom(let eMOMModel):
            // TODO: - Coordinate to emom
            coordinator?.showEMOM(eMOMModel)
            print("emom")
        case .amrap(let aMRAPModel):
            // TODO: - Coordinate to amrap
            print("amrap")
        }
    }
}
