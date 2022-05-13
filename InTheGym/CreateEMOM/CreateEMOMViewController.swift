//
//  CreateEMOMViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CreateEMOMViewController: UIViewController {
    
    // MARK: - Coordination
    weak var coordinator: EmomCreationCoordinator?
    
    var display = CreateEMOMView()
    
    var viewModel = CreateEMOMViewModel()
    
    // MARK: - Properties
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        initDisplay()
        initNavBar()
        setupSubscriptions()
        initialTableSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    func initDisplay() {
        display.tableview.delegate = self
        display.tableview.dataSource = makeDataSource()
        display.timeNumberLabel.text = viewModel.emomTimeLimit.convertToWorkoutTime()
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTime))
        display.timeView.addGestureRecognizer(tap)
    }
    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Finished", style: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        coordinator?.exerciseAddedPublisher = viewModel.exerciseAddedPublisher
        
        viewModel.$exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$validEmom
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$emomTimeLimit
            .sink { [weak self] in self?.display.updateTime(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.initSubscribers()
    }
    
    // MARK: - Actions
    @objc func finished() {
        viewModel.addEMOM()
        coordinator?.completedEmom()

    }
    
    @objc func changeTime() {
        coordinator?.showTimePicker(with: self, time: viewModel.emomTimeLimit)
    }
}

// MARK: - Time Selection
extension CreateEMOMViewController: TimeSelectionParentDelegate {
    func timeSelected(newTime: Int) {
        viewModel.emomTimeLimit = newTime
    }
}

// MARK: - Diffable Table View Source
extension CreateEMOMViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<AddExerciseSections,AddExerciseItems> {
        return UITableViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exercise(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: AMRAPCell.cellID, for: indexPath) as! AMRAPCell
                cell.configure(with: model)
                return cell
            case .adding:
                let cell = tableView.dequeueReusableCell(withIdentifier: NewExerciseCell.cellID, for: indexPath) as! NewExerciseCell
                return cell
            }
        }
    }
    func initialTableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.exercises, .adding])
        currentSnapshot.appendItems([.adding], toSection: .adding)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    func updateTable(with exercises: [ExerciseModel]) {
        let exerciseItems = exercises.map { AddExerciseItems.exercise($0) }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(exerciseItems, toSection: .exercises)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

extension CreateEMOMViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .adding:
            var newExercise = ExerciseModel(workoutPosition: viewModel.exercises.count)
            newExercise.sets = 1
            newExercise.reps = [1]
            newExercise.weight = [" "]
            newExercise.completedSets = [false]
            coordinator?.addNewExercise(newExercise)
        default:
            break
        }
    }
}
