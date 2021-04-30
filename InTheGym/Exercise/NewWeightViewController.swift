//
//  NewWeightViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

// this page is used instead of weightviewcontroller

import UIKit
import SCLAlertView
import Firebase

class NewWeightViewController: UIViewController {
    
    @IBOutlet weak var kgButton:UIButton!
    @IBOutlet weak var lbsButton:UIButton!
    @IBOutlet weak var maxButton:UIButton!
    @IBOutlet weak var percentButton:UIButton!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var kmButton:UIButton!
    @IBOutlet weak var milesButton:UIButton!
    @IBOutlet weak var minsButton:UIButton!
    @IBOutlet weak var secsButton:UIButton!
    
    @IBOutlet weak var text:UITextField!
    @IBOutlet weak var measurement:UITextField!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    // sets and reps varibales to be passed from previous page
    var sets = ""
    var reps = ""
    var variedReps:Bool!
    var repArray = [String]()
    // variables from previous page, body type/exercise name/
    var exercise: String = ""
    var type: String = "weights"
    var completedArray : [Bool] = []
    
    var fromLiveWorkout:Bool!
    var whichExercise:Int!
    var workoutID:String!
    let userID = Auth.auth().currentUser!.uid
    
    @IBAction func buttonPressed(_ sender:UIButton){
        nextButton.isHidden = false
        measurement.text = "\(sender.titleLabel?.text ?? "na")"
        shadowButtons()
        sender.layer.shadowOpacity = 0.0
        sender.backgroundColor = #colorLiteral(red: 0.1190358423, green: 0.2244237083, blue: 0.5393599302, alpha: 1)
        if sender == maxButton{
            text.text = ""
            text.isUserInteractionEnabled = false
            maxButton.isSelected = true
        }else{
            text.isUserInteractionEnabled = true
            maxButton.isSelected = false
            text.becomeFirstResponder()
        }
    }
    
    @IBAction func nextPressed(_ sender:UIButton){
        if  maxButton.isSelected{
            
            if fromLiveWorkout == true{
                //WorkoutDetailViewController.exercises[whichExercise]["reps"] = self.reps as AnyObject
                
                let sets = WorkoutDetailViewController.exercises[whichExercise]["sets"] as! String
                let setInt = Int(sets)! + 1
                let completedSets = Array(repeating: true, count: setInt)
                WorkoutDetailViewController.exercises[whichExercise]["sets"] = String(setInt) as AnyObject
                WorkoutDetailViewController.exercises[whichExercise]["completedSets"] = completedSets as AnyObject
                if var repArray = WorkoutDetailViewController.exercises[whichExercise]["reps"] as? [String]{
                    repArray.append(self.reps)
                    WorkoutDetailViewController.exercises[whichExercise]["reps"] = repArray as AnyObject
                }else{
                    WorkoutDetailViewController.exercises[whichExercise]["reps"] = [self.reps] as AnyObject
                }
                if var weightArray = WorkoutDetailViewController.exercises[whichExercise]["weight"] as? [String]{
                    weightArray.append("MAX")
                    WorkoutDetailViewController.exercises[whichExercise]["weight"] = weightArray as AnyObject
                }else{
                    WorkoutDetailViewController.exercises[whichExercise]["weight"] = ["MAX"] as AnyObject
                }
                
                let workoutRef = Database.database().reference().child("Workouts").child(self.userID).child(self.workoutID)
                workoutRef.updateChildValues(["exercises":WorkoutDetailViewController.exercises])
                
                
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                
            }else{
                print("Continuing to next page with max")
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destVC = Storyboard.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
                destVC.sets = self.sets
                destVC.reps = self.reps
                destVC.weight = "MAX"
                destVC.variedReps = self.variedReps
                destVC.repArray = self.repArray
                destVC.exerciseName = self.exercise
                destVC.type = self.type
                destVC.completedArray = self.completedArray
                self.navigationController?.pushViewController(destVC, animated: true)

            }

        }
        else if text.text == ""{
            showEmptyAlert()
        }else{
            
            if fromLiveWorkout == true{
                //WorkoutDetailViewController.exercises[whichExercise]["reps"] = self.reps as AnyObject
                
                let sets = WorkoutDetailViewController.exercises[whichExercise]["sets"] as! String
                let setInt = Int(sets)! + 1
                let completedSets = Array(repeating: true, count: setInt)
                WorkoutDetailViewController.exercises[whichExercise]["sets"] = String(setInt) as AnyObject
                WorkoutDetailViewController.exercises[whichExercise]["completedSets"] = completedSets as AnyObject
                if var repArray = WorkoutDetailViewController.exercises[whichExercise]["reps"] as? [String]{
                    repArray.append(self.reps)
                    WorkoutDetailViewController.exercises[whichExercise]["reps"] = repArray as AnyObject
                }else{
                    WorkoutDetailViewController.exercises[whichExercise]["reps"] = [self.reps] as AnyObject
                }
                if var weightArray = WorkoutDetailViewController.exercises[whichExercise]["weight"] as? [String]{
                    weightArray.append(text.text! + measurement.text!)
                    WorkoutDetailViewController.exercises[whichExercise]["weight"] = weightArray as AnyObject
                }else{
                    WorkoutDetailViewController.exercises[whichExercise]["weight"] = [text.text! + measurement.text!] as AnyObject
                }
                //WorkoutDetailViewController.exercises[whichExercise]["weight"] = text.text! + measurement.text! as AnyObject
                
                
                let workoutRef = Database.database().reference().child("Workouts").child(self.userID).child(self.workoutID)
                workoutRef.updateChildValues(["exercises":WorkoutDetailViewController.exercises])
                
                
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                
            }else{
                let m = measurement.text!
                let t = text.text!
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destVC = Storyboard.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
                destVC.sets = self.sets
                destVC.reps = self.reps
                destVC.weight = "\(t)\(m)"
                destVC.variedReps = self.variedReps
                destVC.repArray = self.repArray
                destVC.exerciseName = self.exercise
                destVC.type = self.type
                destVC.completedArray = self.completedArray
                self.navigationController?.pushViewController(destVC, animated: true)
                //self.present(destVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func skipPressed(_ sender:UIButton){
        if fromLiveWorkout == true{
            //WorkoutDetailViewController.exercises[whichExercise]["reps"] = self.reps as AnyObject
            
            let sets = WorkoutDetailViewController.exercises[whichExercise]["sets"] as! String
            let setInt = Int(sets)! + 1
            let completedSets = Array(repeating: true, count: setInt)
            WorkoutDetailViewController.exercises[whichExercise]["sets"] = String(setInt) as AnyObject
            WorkoutDetailViewController.exercises[whichExercise]["completedSets"] = completedSets as AnyObject
            if var repArray = WorkoutDetailViewController.exercises[whichExercise]["reps"] as? [String]{
                repArray.append(self.reps)
                WorkoutDetailViewController.exercises[whichExercise]["reps"] = repArray as AnyObject
            }else{
                WorkoutDetailViewController.exercises[whichExercise]["reps"] = [self.reps] as AnyObject
            }
            if var weightArray = WorkoutDetailViewController.exercises[whichExercise]["weight"] as? [String]{
                weightArray.append("")
                WorkoutDetailViewController.exercises[whichExercise]["weight"] = weightArray as AnyObject
            }else{
                WorkoutDetailViewController.exercises[whichExercise]["weight"] = [""] as AnyObject
            }
            //WorkoutDetailViewController.exercises[whichExercise]["weight"] = text.text! + measurement.text! as AnyObject
            
            
            let workoutRef = Database.database().reference().child("Workouts").child(self.userID).child(self.workoutID)
            workoutRef.updateChildValues(["exercises":WorkoutDetailViewController.exercises])
            
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            
        }else{
            
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destVC = Storyboard.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
            destVC.sets = self.sets
            destVC.reps = self.reps
            destVC.weight = ""
            destVC.variedReps = self.variedReps
            destVC.repArray = self.repArray
            destVC.exerciseName = self.exercise
            destVC.type = self.type
            destVC.completedArray = self.completedArray
            self.navigationController?.pushViewController(destVC, animated: true)
        }

    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isHidden = true
        text.keyboardType = .decimalPad
        text.tintColor = .white
        measurement.isUserInteractionEnabled = false
        hideKeyboardWhenTappedAround()
        shadowButtons()
        
        if fromLiveWorkout == true{
            pageNumberLabel.text = "2 of 2"
        }else{
            pageNumberLabel.text = "5 of 6"
        }
        
        
    }
    
    func shadowButtons(){
        let buttons : [UIButton] = [kgButton,lbsButton,maxButton,percentButton,kmButton,milesButton,minsButton,secsButton]
        for button in buttons{
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 5)
            button.layer.shadowRadius = 5
            button.layer.shadowOpacity = 1.0
            button.backgroundColor = #colorLiteral(red: 0, green: 0.3692765302, blue: 0.7998889594, alpha: 1)
        }
    }
    
    func showEmptyAlert(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Continue Anyway") {
            print("continuing to next page with no weight...")
            self.skipPressed(UIButton())
        }
        alert.showError("Enter a Weight!", subTitle: "You have not entered a number for the weight for this exercise. To enter a weight tap on the left side of the big dark blue box. You can continue without entering a weight if you would like. Continue with no weight?", closeButtonTitle: "Cancel!")
    }
    
 
}
