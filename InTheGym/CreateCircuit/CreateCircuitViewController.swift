//
//  CreateCircuitViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import EmptyDataSet_Swift
import Firebase
import Combine

class CreateCircuitViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CircuitCoordinator?
    
    weak var newCoordinator: CircuitCreationCoordinator?
    
    var display = CreateCircuitView()
    
    var viewModel = CreateCircuitViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
    private lazy var dataSource = makeDataSource()

    static var circuitExercises = [exercise]()
    var adapter: CreateCircuitAdapter!
    var delegate = AddWorkoutHomeViewController.self
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completePressed(_:)))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
        initDisplay()
        initialTableSetup()
        setupSubscribers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
        display.tableview.reloadData()
        if CreateCircuitViewController.circuitExercises.count > 0 && !(display.titlefield.text?.isEmpty ?? true) {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func initDisplay() {
        adapter = CreateCircuitAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = makeDataSource()
//        display.tableview.emptyDataSetSource = adapter
//        display.tableview.emptyDataSetDelegate = adapter
        display.tableview.backgroundColor = .white
        display.titlefield.delegate = self
    }
    func initUI(){
        self.navigationItem.title = "Create a Circuit"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Subscribers
    func setupSubscribers() {
        
        viewModel.exercises
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] exercises in
                guard let self = self else {return}
                self.updateTable(with: exercises)
            }
            .store(in: &subscriptions)
        
        viewModel.$validCircuit
            .receive(on: RunLoop.main)
            .sink { [weak self] valid in
                guard let self = self else {return}
                self.navigationItem.rightBarButtonItem?.isEnabled = valid
            }
            .store(in: &subscriptions)
    }
    
    
    // MARK: - Actions
    @IBAction func completePressed(_ sender:UIButton){
        
        viewModel.addCircuit()
        newCoordinator?.upload()
//        let emptyBool : Bool? = display.titlefield.text?.trimmingCharacters(in: .whitespaces).isEmpty
//        if emptyBool == true || emptyBool == nil {
//            showError()
//        } else if CreateCircuitViewController.circuitExercises.count == 0 {
//            let alert = SCLAlertView()
//            alert.showError("Add an Exercise", subTitle: "You must have at least one exercise to add a circuit.", closeButtonTitle: "Ok")
//        } else {
//            var objectExercises : [[String:AnyObject]] = []
//            for ex in CreateCircuitViewController.circuitExercises{
//                objectExercises.append(ex.toObject())
//            }
//
//            let circuitData = ["exercise": display.titlefield.text!.trimTrailingWhiteSpaces(),
//                               "circuitName":display.titlefield.text!.trimTrailingWhiteSpaces(),
//                               "createdBy":ViewController.username!,
//                               "creatorID":Auth.auth().currentUser!.uid,
//                               "integrated":true,
//                               "circuit": true,
//                               "exercises":objectExercises,
//                               "completed":false
//            ] as [String:AnyObject]
//
//            //let newCircuit = circuit(item: circuitData)!
//
//            guard let circuitModel = circuit(item: circuitData) else {return}
//            coordinator?.completedCircuit(circuitModel: circuitModel)
//            //AddWorkoutHomeViewController.exercises.append(circuitData)
//            DisplayTopView.displayTopView(with: "Added Circuit", on: self)
////            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
////            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
//            CreateCircuitViewController.circuitExercises.removeAll()
//        }
    }
    
    @IBAction func addExercise(_ sender:UIButton){
        // go to add page
        if CreateCircuitViewController.circuitExercises.count > 2 {
            let alert = SCLAlertView()
            alert.showError("Too Many Exercises!", subTitle: "A circuit can have a maximum of 3 exercises.")
        } else {
//            guard let newCircuitExercise = exercise() else {return}
//            coordinator?.addExercise(newCircuitExercise)
//            let exerciseViewModel = ExerciseCreationViewModel()
//            exerciseViewModel.exercisekind = .circuit
            newCoordinator?.exercise(viewModel: viewModel)
        }

    }
    
    func showError(){
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Add a title.", closeButtonTitle: "Ok")
    }


}

extension CreateCircuitViewController: CreateCircuitDelegate{
    
    func getData(at indexPath: IndexPath) -> exercise {
        return CreateCircuitViewController.circuitExercises[indexPath.section]
    }
    
    func retreiveNumberOfItems() -> Int {
        return CreateCircuitViewController.circuitExercises.count + 1
    }
    
    func addNewExercise() {
        addExercise(UIButton())
    }
}

extension CreateCircuitViewController : AddingCircuitExerciseDelegate {
    func addedNewCircuitExercise(with circuitModel: circuitExercise) {
        display.tableview.reloadData()
    }
}

extension CreateCircuitViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let empty = textField.text?.isEmpty {
            if !empty && CreateCircuitViewController.circuitExercises.count > 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
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

enum AddExerciseSections {
    case exercises
    case adding
}
enum AddExerciseItems: Hashable {
    case exercise(ExerciseModel)
    case adding
}
