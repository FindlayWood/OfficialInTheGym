//
//  CircuitExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class CircuitExerciseViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    var exerciseName:String!
    var reps:Int!
    var sets:Int!
    var weight:Double?
    var placeHolders = ["Exercise", "Sets", "Reps"]
    var options = ["Integrated", "Save"]
    var descriptions = ["Do you want the exercises to integrate with each other?", "Do you want to save this circuit for later use?"]
    var integrated : Bool = true
    var save : Bool = true
    var delegate : AddingCircuitExerciseDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "CircuitTableViewCell", bundle: nil), forCellReuseIdentifier: "CircuitTableViewCell")
        tableview.register(UINib(nibName: "CircuitOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "CircuitOptionsTableViewCell")
        tableview.backgroundColor = Constants.lightColour
        tableview.tableFooterView = UIView()
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        hideKeyboardWhenTappedAround()
        
        self.navigationItem.title = "Add an Exercise"
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag{
        case 0:
            self.exerciseName = textField.text?.trimTrailingWhiteSpaces()
        case 1:
            self.sets = Int(textField.text ?? "0")
        case 2:
            self.reps = Int(textField.text ?? "0")
        case 3:
            self.weight = Double(textField.text ?? "0.0")
        default:
            break
        }
    }
    
    @IBAction func addPressed(_ sender:UIButton){
        if self.exerciseName == nil || self.reps == nil || self.sets == nil || self.exerciseName == "" {
            let alert = SCLAlertView()
            alert.showError("Fill in all fields.", subTitle: "Make sure all fields are filled in.", closeButtonTitle: "Ok")
        } else {
            let completedArray = Array(repeating: false, count: self.sets)
            let circuitExerciseData = ["exercise":self.exerciseName!,
                                       "reps":self.reps!,
                                       "sets":self.sets!,
                                       "completedSets":completedArray] as [String:AnyObject]
            
            let newCircuitExercise = circuitExercise(item: circuitExerciseData)!
    //        let newCircuitExercise = circuitExercise(exercise: self.exerciseName,
    //                                                 reps: self.reps,
    //                                                 sets: self.sets,
    //                                                 weight: self.weight,
    //                                                 completedSets: completedArray)
            self.delegate.addedNewCircuitExercise(with: newCircuitExercise)
            self.exerciseName = nil
            self.reps = nil
            self.sets = nil
            self.weight = nil
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension CircuitExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CircuitTableViewCell", for: indexPath) as! CircuitTableViewCell
        cell.dataTextField.delegate = self
        cell.placeholder = placeHolders[indexPath.row]
        cell.dataTextField.tag = indexPath.row
        if indexPath.row == 1 || indexPath.row == 2 {
            cell.dataTextField.keyboardType = .numberPad
        } else {
            cell.dataTextField.keyboardType = .default
        }
        return cell
    }
    
}
extension CircuitExerciseViewController : CircuitOptionsDelegate {
    func valueChanged(on cell: UITableViewCell) {
        let index = tableview.indexPath(for: cell)
        switch index?.row {
        case 0:
            integrated.toggle()
        case 1:
            save.toggle()
        default:
            break
        }
    }
}
