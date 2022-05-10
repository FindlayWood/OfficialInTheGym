//
//  CreateAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CreateAMRAPViewController: UIViewController {
    
    weak var coordinator: AMRAPCreationCoordinator?
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel = CreateAMRAPViewModel()
    
    var display = CreateAMRAPView()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
        initialTableSetup()
        initNavBar()
        setupSubscribers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    
    fileprivate func initNavBar() {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func setup() {
        display.tableview.dataSource = makeDataSource()
        display.tableview.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTime))
        display.timeView.addGestureRecognizer(tap)
    }
    
    // MARK: - Subscriptions
    func setupSubscribers() {
        coordinator?.exerciseAddedPublisher = viewModel.exerciseAddedPublisher
        
        viewModel.$exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$validAmrap
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$timeLimit
            .sink { [weak self] in self?.display.updateTime(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.initSubscribers()
    }
}

// MARK: - Actions
extension CreateAMRAPViewController {
    
    @objc func finished() {
        viewModel.addAMRAP()
        coordinator?.completedAmrap()
        
    }
    @objc func changeTime() {
        coordinator?.showTimePicker(with: self, time: viewModel.timeLimit)
    }
}

// MARK: - Time Selection
extension CreateAMRAPViewController: TimeSelectionParentDelegate {
    func timeSelected(newTime: Int) {
        viewModel.timeLimit = newTime
    }
}

// MARK: - Diffable Tableview Source
extension CreateAMRAPViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<AddExerciseSections, AddExerciseItems> {
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
        var currentSnapshot = NSDiffableDataSourceSnapshot<AddExerciseSections,AddExerciseItems>()
        currentSnapshot.appendSections([.exercises, .adding])
        currentSnapshot.appendItems([.adding], toSection: .adding)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    func updateTable(with exercises: [ExerciseModel]) {
        let exerciseItems = exercises.map { AddExerciseItems.exercise($0) }
        var currentSnapshot = NSDiffableDataSourceSnapshot<AddExerciseSections,AddExerciseItems>()
        currentSnapshot.appendSections([.exercises,.adding])
        currentSnapshot.appendItems([.adding], toSection: .adding)
        currentSnapshot.appendItems(exerciseItems, toSection: .exercises)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
extension CreateAMRAPViewController: UITableViewDelegate {
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
