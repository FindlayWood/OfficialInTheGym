//
//  GroupWeightViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class GroupWeightViewController: UIViewController {
    
    //variables loaded from previous pages
    var sets: String = ""
    var exercise: String = ""
    var reps: String = ""
    
    //outlet to weight textfield
    @IBOutlet var weightField: UITextField!
    @IBOutlet var percentField:UITextField!
    
    //outlet function to add exercise to list
    // MARK: no weight
    @IBAction func addPressed(_ sender:UIButton){
        sender.pulsate()
        
        let alert = SCLAlertView()
        alert.addButton("YES") {
            
            // MARK: new
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
            SVC.sets = self.sets
            SVC.exercise = self.exercise
            SVC.reps = self.reps
            SVC.weight = ""
            self.navigationController?.pushViewController(SVC, animated: true)
            
            
            
            // MARK: old
            
            
            /*let dictData = ["exercise": self.exercise,
                            "sets": self.sets,
                            "reps": self.reps,
                            "weight": ""]
            
            GroupAddViewController.groupExercises.append(dictData)
            
            // new alert - must test with popping view controllers
            let alert = SCLAlertView()
            alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
        }
        alert.showWarning("No Weight?", subTitle: "Are you sure you want to add this exercise with no specific weight?", closeButtonTitle: "NO")
        
    }
    
    // function if max weight is pressed
    // MARK: max
    @IBAction func maxPressed(_ sender:UIButton){
        sender.pulsate()
        let alert = SCLAlertView()
        alert.addButton("YES") {
            
            // new section for going to note page
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
            SVC.sets = self.sets
            SVC.exercise = self.exercise
            SVC.reps = self.reps
            SVC.weight = "MAX"
            self.navigationController?.pushViewController(SVC, animated: true)
            // end of going to note page section
            
            
            
            
            /*let dictData = ["exercise": self.exercise,
                            "sets": self.sets,
                            "reps": self.reps,
                            "max": "MAX"
            ]
            GroupAddViewController.groupExercises.append(dictData)
            let alert = SCLAlertView()
            alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            
        }
        alert.showWarning("MAX", subTitle: "Are you sure you want to choose MAX as the weight?", closeButtonTitle: "NO")
    }
    
    
    // handle the pressing of specific weight
    // MARK: kg
    @IBAction func weightPressed(_ sender:UIButton){
        if (weightField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!{
            let alert = SCLAlertView()
            alert.addButton("Continue") {
                
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = ""
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                //MARK: old
                
                
                /*if let weightAmount = self.weightField.text{
                    let dictData = ["exercise": self.exercise,
                                    "sets": self.sets,
                                    "reps": self.reps,
                                    "weight": "\(weightAmount)"]
                    
                    GroupAddViewController.groupExercises.append(dictData)
                    
                    // new alert - must test with popping view controllers
                    let alert = SCLAlertView()
                    alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                    self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)
                }*/
            }
            alert.showWarning("Empty", subTitle: "You have pressed ADD but the text field is empty. Did you mean to enter a weight? If you continue the exercise will be added with no specified wight.", closeButtonTitle: "Cancel")
        }
        else{
            if let weightAmount = self.weightField.text{
                
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = "\(weightAmount)kg"
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                //MARK: old
//                let dictData = ["exercise": self.exercise,
//                                "sets": self.sets,
//                                "reps": self.reps,
//                                "weight": "\(weightAmount)"]
//                
//                GroupAddViewController.groupExercises.append(dictData)
                
                // new alert - must test with popping view controllers
                /*let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            }
        }
    }
    
    
    // handle the pressing of percent
    // MARK: percent
    @IBAction func percentPressed(_ sender:UIButton){
        if (percentField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!{
            let alert = SCLAlertView()
            alert.addButton("Continue") {
                
                
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = ""
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                //MARK: old
                /*if let percent = self.percentField.text{
                    let dictData = ["exercise": self.exercise,
                                    "sets": self.sets,
                                    "reps": self.reps,
                                    "percent": "\(percent)"
                    ]
                    
                    GroupAddViewController.groupExercises.append(dictData)
                    
                    // new alert - must test with popping view controllers
                    let alert = SCLAlertView()
                    alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                    self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)
                }*/
            }
            alert.showWarning("Empty", subTitle: "You have pressed ADD but the text field is empty. Did you mean to enter a %? If you continue the exercise will be added with no specified wight.")
        }
        else{
            if let percent = self.percentField.text{
                
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = "\(percent)%"
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                
                //MARK: old
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "percent": "\(percent)"
                ]
                
                GroupAddViewController.groupExercises.append(dictData)
                
                // new alert - must test with popping view controllers
                let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}
