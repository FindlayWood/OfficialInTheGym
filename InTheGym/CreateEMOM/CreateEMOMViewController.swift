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
    weak var coordinator: EMOMCoordinator?
    
    weak var newCoordinator: EmomCreationCoordinator?
    
    var display = CreateEMOMView()
    
    var adapter: CreateEMOMAdapter!
    
    var viewModel = CreateEMOMViewModel()
    
    // MARK: - Properties
    static var exercises = [exercise]()
    
//    var EMOMTime: Int = 10 {
//        didSet {
//            display.timeNumberLabel.text = EMOMTime.description + " mins"
//        }
//    }
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initNavBar()
        setupSubscriptions()
        initialTableSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
//        display.tableview.reloadData()
//        if CreateEMOMViewController.exercises.count > 0 {
//            navigationItem.rightBarButtonItem?.isEnabled = true
//        }
    }
    
    func initDisplay() {
        adapter = .init()
        display.tableview.delegate = adapter
        display.tableview.dataSource = makeDataSource()
        display.timeNumberLabel.text = viewModel.emomTimeLimit.description + " mins"
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
        viewModel.exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] exercises in
                guard let self = self else {return}
                self.updateTable(with: exercises)
                self.navigationItem.rightBarButtonItem?.isEnabled = exercises.count > 0
            }
            .store(in: &subscriptions)
        
        adapter.rowTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] indexPath in
                guard let self = self else {return}
                if indexPath.section == 1 {
                    self.addNewExercise()
                }
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    @objc func finished() {
//        var objectExercises = [[String:AnyObject]]()
//        for ex in CreateEMOMViewController.exercises {
//            objectExercises.append(ex.toObject())
//        }
//        let emomTimeLimit = EMOMTime * 60
//        let emomData = ["timeLimit": emomTimeLimit,
//                         "exercises": objectExercises] as [String:AnyObject]
//        guard let emomModel = EMOM(data: emomData) else {return}
//        coordinator?.competedEMOM(emomModel: emomModel)
//
////        let emomObject = emomModel.toObject()
////        AddWorkoutHomeViewController.exercises.append(emomObject)
//        DisplayTopView.displayTopView(with: "Added EMOM", on: self)
////        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
////        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
//        CreateEMOMViewController.exercises.removeAll()
//        EMOMTime = 10
        viewModel.addEMOM()
        newCoordinator?.upload()
    }
    
    @objc func changeTime() {
        newCoordinator?.showTimePicker(with: self, time: viewModel.emomTimeLimit)
    }
    func addNewExercise() {
//        guard let newEMOMExercise = exercise() else {return}
//        coordinator?.addExercise(newEMOMExercise)
        newCoordinator?.exercise(viewModel: viewModel, workoutPosition: viewModel.exercises.value.count)
    }
}

//extension CreateEMOMViewController: CreateEMOMProtocol {
//    func numberOfExercises() -> Int {
//        return CreateEMOMViewController.exercises.count + 1
//        //return viewModel.numberOfExercises
//    }
//
//    func getData(at indexPath: IndexPath) -> exercise {
//        return CreateEMOMViewController.exercises[indexPath.section]
//        //return viewModel.getData(at: indexPath)
//    }
//
//    func addNewExercise() {
////        guard let newEMOMExercise = exercise() else {return}
////        coordinator?.addExercise(newEMOMExercise)
//        newCoordinator?.exercise(viewModel: viewModel, workoutPosition: viewModel.exercises.value.count)
//    }
//}

// MARK: - Time Selection
extension CreateEMOMViewController: TimeSelectionParentDelegate {
    func timeSelected(newTime: Int) {
        viewModel.emomTimeLimit = newTime
        display.updateTime(with: newTime)
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
