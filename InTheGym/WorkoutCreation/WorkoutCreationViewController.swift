//
//  WorkoutCreationViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import EmptyDataSet_Swift

class WorkoutCreationViewController: UIViewController {

    // MARK: - Display
    var display = WorkoutCreationView()
    
    // MARK: - Coordinator
    weak var coordinator: WorkoutCreationCoordinator?
    
    // MARK: - Properties
    private lazy var dataSource = makeDataSource()
    
    var viewModel = WorkoutCreationViewModel()
    
    var adapter: WorkoutCreationAdapter!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Exercise Types
//    var exerciseTypes: [ExerciseType] {
//        let exercises: [ExerciseType] = exercises + circuits + emoms + amraps
//        return exercises.sorted(by: { $0.workoutPosition > $1.workoutPosition })
//    }
    
//    var exercises = [ExerciseModel]()
//    var circuits = [CircuitModel]()
//    var emoms = [EMOMModel]()
//    var amraps = [AMRAPModel]()
    
    // MARK: - View setup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Create Workout"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        display.exercisesTableView.dataSource = dataSource
        initAdapter()
        initialTableSetup()
        setUpActions()
        initNavBar()
        setupSubscribers()
    }
    
    func initAdapter() {
        adapter = .init()
        display.exercisesTableView.separatorStyle = .singleLine
        //display.exercisesTableView.emptyDataSetSource = adapter
    }
    
    func initNavBar() {
        let uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadPressed(_:)))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.rightBarButtonItem?.isEnabled = isNavBarEnabled()
    }
    
    func isNavBarEnabled() -> Bool {
//        if exerciseTypes.count > 0 { return true }
//        else { return false }
        return false
    }
    
    func setUpActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
    }
    
    //MARK: - Subscribers
    func setupSubscribers() {
        viewModel.exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] exercises in
                guard let self = self else {return}
                self.updateTable(with: exercises)
            }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
extension WorkoutCreationViewController {
    @objc func uploadPressed(_ sender: UIBarButtonItem) {
        coordinator?.upload()
    }
    @objc func plusButtonPressed(_ sender: UIButton) {
        coordinator?.plus(viewModel: viewModel, workoutPosition: viewModel.exercises.value.count)
    }
}

// MARK: - TableViewDataSource
extension WorkoutCreationViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int,ExerciseRow> {
        return UITableViewDiffableDataSource(tableView: display.exercisesTableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exercise(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCreationTableViewCell.cellID, for: indexPath) as! ExerciseCreationTableViewCell
                cell.configure(with: model)
                return cell
            case .circuit(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: CircuitCreationTableViewCell.cellID, for: indexPath) as! CircuitCreationTableViewCell
                cell.configure(with: model)
                return cell
            case .emom(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: EmomCreationTableViewCell.cellID, for: indexPath) as! EmomCreationTableViewCell
                cell.configure(with: model)
                return cell
            case .amrap(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: AmrapCreationTableViewCell.cellID, for: indexPath) as! AmrapCreationTableViewCell
                cell.configure(with: model)
                return cell
            }
        }
    }
    func initialTableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([0])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updateTable(with exercises: [ExerciseType]) {
        if exercises.isEmpty {
            display.emptyMessage.isHidden = false
        } else {
            display.emptyMessage.isHidden = true
        }
        var currentSnapshot = dataSource.snapshot()
        for type in exercises {
            switch type {
            case is ExerciseModel:
                currentSnapshot.appendItems([.exercise(type as! ExerciseModel)], toSection: 0)
            case is CircuitModel:
                currentSnapshot.appendItems([.circuit(type as! CircuitModel)], toSection: 0)
            case is EMOMModel:
                currentSnapshot.appendItems([.emom(type as! EMOMModel)], toSection: 0)
            case is AMRAPModel:
                currentSnapshot.appendItems([.amrap(type as! AMRAPModel)], toSection: 0)
            default:
                break
            }
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

enum ExerciseRow: Hashable {
    case exercise(ExerciseModel)
    case circuit(CircuitModel)
    case emom(EMOMModel)
    case amrap(AMRAPModel)
}
