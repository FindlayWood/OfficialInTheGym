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
    
    weak var coordinator: CircuitFlow?
    
    @IBOutlet weak var titleField:UITextField!
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var completeButton:UIButton!
    

    var circuitExercises : [circuitExercise] = []
    var adapter : CreateCircuitAdapter!
    var delegate = AddWorkoutHomeViewController.self
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = CreateCircuitAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.emptyDataSetSource = adapter
        tableview.emptyDataSetDelegate = adapter
        tableview.register(UINib(nibName: "CircuitExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CircuitExerciseTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
        tableview.backgroundColor = Constants.lightColour
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
    }
    
    func initUI(){
        self.navigationItem.title = "Create a Circuit"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        titleField.delegate = self
    }
    
    
    // MARK: - Actions
    @IBAction func completePressed(_ sender:UIButton){
        let emptyBool : Bool? = titleField.text?.trimmingCharacters(in: .whitespaces).isEmpty
        if emptyBool == true || emptyBool == nil {
            showError()
        } else if circuitExercises.count == 0 {
            let alert = SCLAlertView()
            alert.showError("Add an Exercise", subTitle: "You must have at least one exercise to add a circuit.", closeButtonTitle: "Ok")
        } else {
            var objectExercises : [[String:AnyObject]] = []
            for ex in self.circuitExercises{
                objectExercises.append(ex.toObject())
            }
            
            let circuitData = ["exercise": titleField.text!.trimTrailingWhiteSpaces(),
                               "circuitName":titleField.text!.trimTrailingWhiteSpaces(),
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
        if self.circuitExercises.count > 4 {
            let alert = SCLAlertView()
            alert.showError("Too Many Exercises!", subTitle: "A circuit can have a maximum of 5 exercises.")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "CircuitExerciseViewController") as! CircuitExerciseViewController
            nextVC.delegate = self
            self.navigationController?.pushViewController(nextVC, animated: true)
        }

    }
    
    func showError(){
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Add a title.", closeButtonTitle: "Ok")
    }


}

extension CreateCircuitViewController: CreateCircuitDelegate{
    func getData(at indexPath: IndexPath) -> circuitExercise {
        return circuitExercises[indexPath.section]
    }
    
    func retreiveNumberOfItems() -> Int {
        return circuitExercises.count
    }
}

extension CreateCircuitViewController : AddingCircuitExerciseDelegate {
    func addedNewCircuitExercise(with circuitModel: circuitExercise) {
        circuitExercises.append(circuitModel)
        self.tableview.reloadData()
    }
}
