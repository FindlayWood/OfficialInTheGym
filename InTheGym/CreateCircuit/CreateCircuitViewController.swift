//
//  CreateCircuitViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import Combine

class CreateCircuitViewController: UIViewController {
    
//    weak var coordinator: CircuitCoordinator?
    
    weak var coordinator: CircuitCreationCoordinator?
    
    var display = CreateCircuitView()
    
    var viewModel = CreateCircuitViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        initDisplay()
        initNavBar()
        initialTableSetup()
        setupSubscribers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    func initNavBar() {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completePressed(_:)))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initDisplay() {
        display.tableview.dataSource = makeDataSource()
        display.tableview.delegate = self
        display.tableview.backgroundColor = .secondarySystemBackground
        display.titlefield.delegate = self
    }

    
    // MARK: - Subscribers
    func setupSubscribers() {
        coordinator?.exerciseAddedPublisher = viewModel.addedExercisePublisher
        
        viewModel.$exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$validCircuit
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        viewModel.initSubscribers()
    }
    
    
    // MARK: - Actions
    @objc func completePressed(_ sender:UIButton){
        viewModel.addCircuit()
        coordinator?.completedCircuit()
    }
    
    func showError(){
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Add a title.", closeButtonTitle: "Ok")
    }


}

extension CreateCircuitViewController {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let empty = textField.text?.isEmpty {
//            if !empty && CreateCircuitViewController.circuitExercises.count > 0 {
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//            }
//        }
//    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        if textField == display.titlefield {
            viewModel.updateTitle(with: newString)
        }
        return true
    }
}
extension CreateCircuitViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<AddExerciseSections,AddExerciseItems> {
        return UITableViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .exercise(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: CircuitCell.cellID, for: indexPath) as! CircuitCell
                cell.setup(with: model)
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
        currentSnapshot.appendItems(exerciseItems, toSection: .exercises)
        currentSnapshot.appendItems([.adding], toSection: .adding)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
extension CreateCircuitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        switch item {
        case .adding:
            let newExercise = ExerciseModel(workoutPosition: viewModel.exercises.count)
            coordinator?.addNewExercise(newExercise)
        default:
            break
        }
    }
}

enum AddExerciseSections {
    case exercises
    case adding
}
enum AddExerciseItems: Hashable {
    case exercise(ExerciseModel)
    case adding
}
