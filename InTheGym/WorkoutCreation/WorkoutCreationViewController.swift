//
//  WorkoutCreationViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutCreationViewController: UIViewController {

    // MARK: - Display
    var display = WorkoutCreationView()
    
    // MARK: - Coordinator
    weak var coordinator: RegularWorkoutCreationCoordinator?
    
    // MARK: - Properties
    private lazy var dataSource = makeDataSource()
    
    var viewModel = WorkoutCreationViewModel()
    
    // MARK: - Store Subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - View setup
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        display.exercisesTableView.dataSource = dataSource
        initAdapter()
        initialTableSetup()
        setUpActions()
        initNavBar()
        initDisplay()
        setupSubscribers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Create Workout"
    }
    
    func initAdapter() {
        display.exercisesTableView.separatorStyle = .singleLine
        display.exercisesTableView.backgroundColor = .secondarySystemBackground
    }
    
    func initNavBar() {
        let uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadPressed(_:)))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    // MARK: - Display
    func initDisplay() {
        display.titleTextField.delegate = self
    }
    // MARK: - Targets
    func setUpActions() {
        display.plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
        display.optionsButton.addTarget(self, action: #selector(optionsButtonActions(_:)), for: .touchUpInside)
    }
    
    //MARK: - Subscribers
    func setupSubscribers() {
        
        coordinator?.completedExercise = viewModel.addedExercisePublisher
        coordinator?.completedCircuit = viewModel.addedCircuitPublisher
        coordinator?.completedAmrap = viewModel.addedAmrapPublisher
        
        viewModel.$exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$canUpload
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.successfullyUploadedWorkout
            .sink { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.display.reset()
                    self.displayTopMessage(with: "Uploaded Workout!")
                    self.viewModel.reset()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.errorUploadingWorkout
            .sink { [weak self] error in
                guard let self = self else {return}
                if error {
                    self.displayTopMessage(with: "Error! Please try again.")
                }
            }
            .store(in: &subscriptions)
        viewModel.optionSubscriptions()
    }
}
// MARK: - Actions
extension WorkoutCreationViewController {
    @objc func uploadPressed(_ sender: UIBarButtonItem) {
        viewModel.upload()
    }
    @objc func plusButtonPressed(_ sender: UIButton) {
        let newExercise = ExerciseModel(workoutPosition: viewModel.exercises.count)
        coordinator?.addNewExercise(newExercise)
    }
    @objc func optionsButtonActions(_ sender: UIButton) {
        let navigationModel = WorkoutCreationOptionsNavigationModel(
            isSaving: viewModel.isSaving,
            isPrivate: viewModel.isPrivate,
            assignTo: viewModel.assignTo,
            currentTags: viewModel.workoutTags,
            toggledSaving: viewModel.toggledSaving,
            toggledPrivacy: viewModel.toggledPrivacy,
            addedNewTag: viewModel.addedNewTag)
        coordinator?.workoutOptions(navigationModel)
    }
}

// MARK: - TableViewDataSource
extension WorkoutCreationViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<SingleSection,ExerciseRow> {
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
            case .amrap(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: AmrapCreationTableViewCell.cellID, for: indexPath) as! AmrapCreationTableViewCell
                cell.configure(with: model)
                return cell
            }
        }
    }
    func initialTableSetup() {
        var currentSnapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseRow>()
        currentSnapshot.appendSections([.main])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    func updateTable(with exercises: [ExerciseType]) {
        if exercises.isEmpty {
            display.emptyMessage.isHidden = false
        } else {
            display.emptyMessage.isHidden = true
        }
        var currentSnapshot = NSDiffableDataSourceSnapshot<SingleSection,ExerciseRow>()
        currentSnapshot.appendSections([.main])
        for type in exercises {
            switch type {
            case is ExerciseModel:
                currentSnapshot.appendItems([.exercise(type as! ExerciseModel)], toSection: .main)
            case is CircuitModel:
                currentSnapshot.appendItems([.circuit(type as! CircuitModel)], toSection: .main)
            case is AMRAPModel:
                currentSnapshot.appendItems([.amrap(type as! AMRAPModel)], toSection: .main)
            default:
                break
            }
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
// MARK: - Textfield Delegation
extension WorkoutCreationViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        if textField == display.titleTextField {
            viewModel.updateTitle(with: newString)
        }
        return true
    }
}
enum ExerciseRow: Hashable {
    case exercise(ExerciseModel)
    case circuit(CircuitModel)
    case amrap(AMRAPModel)
}
