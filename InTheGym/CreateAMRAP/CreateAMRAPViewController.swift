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
    
    weak var coordinator: AMRAPCoordinator?
    
    weak var newCoordinator: AmrapCreationCoordinator?
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel = CreateAMRAPViewModel()
    
    static var exercises = [exercise]()
    var amrapTime: Int = 10
    var adapter: CreateAMRAPAdapter?
    var amrapView = CreateAMRAPView()
    var timeSelectedView = TimeSelectionView()
    var flashView = FlashView()
    
    private var bottomViewHeight = Constants.screenSize.height * 0.5

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finished))
//        navigationItem.rightBarButtonItem = button
//        navigationItem.rightBarButtonItem?.isEnabled = false
        setup()
        initialTableSetup()
        initNavBar()
        setupSubscribers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        amrapView.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(amrapView)
//        setup()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Create AMRAP"
        editNavBarColour(to: .darkColour)
//        amrapView.tableview.reloadData()
//        if CreateAMRAPViewController.exercises.count > 0 {
//            navigationItem.rightBarButtonItem?.isEnabled = true
//        }
    }
    fileprivate func initNavBar() {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func setup() {
        adapter = CreateAMRAPAdapter(delegate: self)
        amrapView.tableview.delegate = adapter
        amrapView.tableview.dataSource = makeDataSource()
        amrapView.timeNumberLabel.text = amrapTime.description + " mins"
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTime))
        amrapView.timeView.addGestureRecognizer(tap)
    }
    
    // MARK: - Subscriptions
    func setupSubscribers() {
        viewModel.exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] exercises in
                guard let self = self else {return}
                self.updateTable(with: exercises)
                self.navigationItem.rightBarButtonItem?.isEnabled = exercises.count > 0
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
extension CreateAMRAPViewController {
    @objc func addExercise() {
        newCoordinator?.exercise(viewModel: viewModel, exercisePosition: viewModel.exercises.value.count)
//        if CreateAMRAPViewController.exercises.count < 10 {
//            guard let newAMRAPExercise = exercise() else {return}
//            coordinator?.addExercise(newAMRAPExercise)
//        }
    }
    
    @objc func finished() {
        viewModel.addAMRAP()
        newCoordinator?.upload()
//        var objectExercises = [[String:AnyObject]]()
//        for ex in CreateAMRAPViewController.exercises {
//            objectExercises.append(ex.toObject())
//        }
//        let amrapData = ["timeLimit": amrapTime,
//                         "exercises": objectExercises] as [String:AnyObject]
//        guard let amrapModel = AMRAP(data: amrapData) else {return}
//        coordinator?.completedAMRAP(amrapModel: amrapModel)
////        let amrapObject = amrapModel.toObject()
////        AddWorkoutHomeViewController.exercises.append(amrapObject)
//        DisplayTopView.displayTopView(with: "Added AMRAP", on: self)
////        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
////        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
//        CreateAMRAPViewController.exercises.removeAll()
    }
}

extension CreateAMRAPViewController: CreateAMRAPProtocol {
    func getData(at indexPath: IndexPath) -> exercise {
        return CreateAMRAPViewController.exercises[indexPath.section]
    }
    func addNewExercise() {
        addExercise()
    }
    func numberOfExercises() -> Int {
        return CreateAMRAPViewController.exercises.count + 1
    }
    @objc func changeTime() {
        timeSelectedView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: bottomViewHeight)
        flashView.frame = CGRect(x: 0, y: 0 - view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
        flashView.alpha = 0
        amrapView.addSubview(flashView)
        amrapView.addSubview(timeSelectedView)
        timeSelectedView.delegate = self
        timeSelectedView.flashview = flashView
        let showFrame = CGRect(x: 0, y: Constants.screenSize.height - bottomViewHeight - view.safeAreaInsets.top, width: view.frame.width, height: bottomViewHeight)
        UIView.animate(withDuration: 0.2) {
            self.timeSelectedView.frame = showFrame
            self.flashView.alpha = 0.4
            self.amrapView.timeView.layer.shadowOpacity = 0
            self.flashView.isUserInteractionEnabled = true
        }
    }
    func timeSelected(newTime: Int) {
        amrapTime = newTime
        viewModel.timeLimit = newTime
        amrapView.timeNumberLabel.text = newTime.description + " mins"
        amrapView.timeView.layer.shadowOpacity = 1.0
    }
    func getTime() -> Int {
        return amrapTime
    }
}

// MARK: - Diffable Tableview Source
extension CreateAMRAPViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<AddExerciseSections, AddExerciseItems> {
        return UITableViewDiffableDataSource(tableView: amrapView.tableview) { tableView, indexPath, itemIdentifier in
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
