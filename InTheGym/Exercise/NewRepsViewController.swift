//
//  NewRepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

//this is the new reps page. it is used instead of repviewcontroller

import UIKit
import SCLAlertView

class NewRepsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variables from previous page, body type/exercise name/sets/varied
    var exercise: String = ""
    var type: String = "weights"
    var varyReps: Bool = false
    var sets : String = ""
    var completedArray : [Bool] = []
    
    // if reps are varied this will hold all the reps
    var repArray = [String]()
    
    var whatSet : Int = 0
    
    var setsAndReps : [[String:String]] = []
    
    @IBOutlet weak var text:UITextField!
    
    @IBOutlet weak var setLabel:UILabel!
    
    @IBOutlet weak var tableview:UITableView!
    
    @IBOutlet weak var continueButton:UIButton!
    @IBOutlet weak var nextButton:UIButton!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    
    var fromLiveWorkout:Bool!
    var whichExercise:Int!
    var workoutID:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.layer.borderColor = UIColor.white.cgColor
        text.layer.borderWidth = 4
        text.layer.cornerRadius = 6
        text.keyboardType = .numberPad
        text.becomeFirstResponder()
        text.tintColor = .white
        hideKeyboardWhenTappedAround()
        
        self.tableview.rowHeight = 60
        self.tableview.layer.cornerRadius = 10
        
        self.navigationItem.title = "Reps"
        
        
        
        if (!varyReps){
            tableview.isHidden = true
            self.setLabel.isHidden = true
            self.nextButton.isHidden = true
        }else{
            let setNumber = Int(self.sets)!
            self.setLabel.text = "SET 1 / SET \(setNumber)"
            self.continueButton.isHidden = true
        }
        
        if fromLiveWorkout == true{
            pageNumberLabel.text = "1 0f 2"
        }else{
            pageNumberLabel.text = "4 of 6"
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func textFieldBeginEdit(_ sender:UITextField){
        if sender.text == "MAX"{
            sender.text = ""
        }
    }
    
    @IBAction func maxPressed(_ sender:UIButton){
        text.text = "MAX"
    }
    
    @IBAction func continuePressed(_ sender:UIButton){
        if text.text == ""{
            showError()
        }else{
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destVC = Storyboard.instantiateViewController(withIdentifier: "NewWeightViewController") as! NewWeightViewController
            destVC.sets = self.sets
            destVC.variedReps = self.varyReps
            destVC.exercise = self.exercise
            destVC.type = self.type
            destVC.completedArray = self.completedArray
            if varyReps{
                destVC.repArray = self.repArray
            }else{
                destVC.reps = text.text!
            }
            destVC.fromLiveWorkout = self.fromLiveWorkout
            destVC.whichExercise = self.whichExercise
            destVC.workoutID = self.workoutID
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
        //self.present(destVC, animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: UIButton){
        if varyReps == false{
            if text.text != ""{
                //onto next page
                print("onto next page")
                print("\(self.sets) sets of \(text.text!) reps")
            }
            else{
                showError()
            }
        }
        else{
            if text.text != ""{
                let setNumber = Int(self.sets)! - 1
                if whatSet < setNumber{
                    let rep = text.text!
                    //let repInt = Int(rep)!
                    repArray.append(rep)
                    setsAndReps.append(["Set \(whatSet + 1)": rep])
                    self.text.text = ""
                    self.setLabel.text = "SET \(whatSet+2) / SET \(setNumber + 1)"
                    self.whatSet += 1
                    self.tableview.reloadData()
                    self.text.becomeFirstResponder()
                }
                else{
                    let rep = text.text!
                    //let repInt = Int(rep)!
                    repArray.append(rep)
                    setsAndReps.append(["Set \(whatSet + 1)": rep])
                    self.continueButton.isHidden = false
                    self.nextButton.isHidden = true
                    print(repArray)
                    print(self.sets)
                    print("onto next page")
                    self.tableview.reloadData()
                }
            }
            else{
                showError()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsAndReps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! RepsTableViewCell
        cell.setsLabel.text = "Set \(indexPath.row + 1)"
        let repString = repArray[indexPath.row]
        cell.repsText.text = "\(repString)"
        
        return cell
    }
    
    
    
    func showError(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("Enter a Rep Amount!", subTitle: "You have not entered a number for the reps for this exercise. To enter a number tap on the big dark blue box. You must enter a rep number to continue.", closeButtonTitle: "Ok")
    }


}
