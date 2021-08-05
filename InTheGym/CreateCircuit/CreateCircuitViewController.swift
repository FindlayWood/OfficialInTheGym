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

class CreateCircuitViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CircuitCoordinator?
    
    var display = CreateCircuitView()

    static var circuitExercises = [exercise]()
    var adapter: CreateCircuitAdapter!
    var delegate = AddWorkoutHomeViewController.self
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completePressed(_:)))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
        initDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
        display.tableview.reloadData()
        if CreateCircuitViewController.circuitExercises.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func initDisplay() {
        adapter = CreateCircuitAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.emptyDataSetSource = adapter
        display.tableview.emptyDataSetDelegate = adapter
        display.tableview.backgroundColor = .white
    }
    func initUI(){
        self.navigationItem.title = "Create a Circuit"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
        display.titlefield.delegate = self
    }
    
    
    // MARK: - Actions
    @IBAction func completePressed(_ sender:UIButton){
        let emptyBool : Bool? = display.titlefield.text?.trimmingCharacters(in: .whitespaces).isEmpty
        if emptyBool == true || emptyBool == nil {
            showError()
        } else if CreateCircuitViewController.circuitExercises.count == 0 {
            let alert = SCLAlertView()
            alert.showError("Add an Exercise", subTitle: "You must have at least one exercise to add a circuit.", closeButtonTitle: "Ok")
        } else {
            var objectExercises : [[String:AnyObject]] = []
            for ex in CreateCircuitViewController.circuitExercises{
                objectExercises.append(ex.toObject())
            }
            
            let circuitData = ["exercise": display.titlefield.text!.trimTrailingWhiteSpaces(),
                               "circuitName":display.titlefield.text!.trimTrailingWhiteSpaces(),
                               "createdBy":ViewController.username!,
                               "creatorID":Auth.auth().currentUser!.uid,
                               "integrated":true,
                               "circuit": true,
                               "exercises":objectExercises,
                               "completed":false
            ] as [String:AnyObject]
            
            //let newCircuit = circuit(item: circuitData)!
            

            AddWorkoutHomeViewController.exercises.append(circuitData)
            DisplayTopView.displayTopView(with: "Added Circuit", on: self)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    @IBAction func addExercise(_ sender:UIButton){
        // go to add page
        if CreateCircuitViewController.circuitExercises.count > 2 {
            let alert = SCLAlertView()
            alert.showError("Too Many Exercises!", subTitle: "A circuit can have a maximum of 3 exercises.")
        } else {
            guard let newCircuitExercise = exercise() else {return}
            coordinator?.addExercise(newCircuitExercise)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let nextVC = storyboard.instantiateViewController(withIdentifier: "CircuitExerciseViewController") as! CircuitExerciseViewController
//            nextVC.delegate = self
//            self.navigationController?.pushViewController(nextVC, animated: true)
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
        //CreateCircuitViewController.circuitExercises.append(circuitModel)
        display.tableview.reloadData()
    }
}
