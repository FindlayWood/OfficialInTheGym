//
//  GroupDistanceViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

// adding distnace page for cardio exercises

import UIKit
import SCLAlertView

class GroupDistanceViewController: UIViewController {

    var sets: String = ""
    var exercise: String = ""
    var reps: String = ""
    
    // outlet to km textfield
    @IBOutlet var kmField: UITextField!
    
    
    // outlet to metres textfield
    @IBOutlet var metresField:UITextField!
    
    // outlet to minutes textfield
    @IBOutlet var minField:UITextField!
    
    
    //MARK: no unit
    @IBAction func addPressed(_ sender:UIButton){
        sender.pulsate()
        // MARK: new
        // new section for going to note page
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
        SVC.sets = self.sets
        SVC.exercise = self.exercise
        SVC.reps = self.reps
        SVC.weight = ""
        self.navigationController?.pushViewController(SVC, animated: true)
        // end of going to note page section
        
        /*let dictData = ["exercise": self.exercise,
                        "sets": self.sets,
                        "reps": self.reps,
                        "distance": ""]
            
        GroupAddViewController.groupExercises.append(dictData)
            
        // new alert - must test with popping view controllers
        let alert = SCLAlertView()
        alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        kmField.keyboardType = .numberPad
        metresField.keyboardType = .numberPad
        minField.keyboardType = .numberPad

    }
    
    // function to upload metres
    // MARK: metres
    @IBAction func metresPressed(_ sender:UIButton){
        if (metresField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            let alert = SCLAlertView()
            alert.addButton("Yes") {
                
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = ""
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "distance": ""
                ]
                GroupAddViewController.groupExercises.append(dictData)
                    
                // new alert - must test with popping view controllers
                let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            }
            alert.showWarning("Empty", subTitle: "You have pressed ADD but the text field is empty. Did you mean to enter a distance? If you continue the exercise will be added with no specified distance.", closeButtonTitle: "Cancel")
        }
        else{
            if let metres = metresField.text{
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = "\(metres)m"
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "metres": "\(metres)"
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
    
    //MARK: km
    @IBAction func kmPressed(_ sender:UIButton){
        if (kmField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!{
            let alert = SCLAlertView()
            alert.addButton("Yes") {
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = ""
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "distance": ""
                ]
                GroupAddViewController.groupExercises.append(dictData)
                
                // new alert - must test with popping view controllers
                let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            }
            alert.showWarning("Empty", subTitle: "You have pressed ADD but the text field is empty. Did you mean to enter a distance? If you continue the exercise will be added with no specified distance.", closeButtonTitle: "Cancel")
        }
        else{
            if let km = kmField.text{
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = "\(km)km"
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "distance": "\(km)"
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
    
    // MARK: minutes
    @IBAction func timePressed(_ sender:UIButton){
        if (minField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!{
            let alert = SCLAlertView()
            alert.addButton("Yes") {
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = ""
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "distance": ""
                ]
                GroupAddViewController.groupExercises.append(dictData)
                
                // new alert - must test with popping view controllers
                let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 6], animated: true)*/
            }
            alert.showWarning("Empty", subTitle: "You have pressed ADD but the text field is empty. Did you mean to enter a time? If you continue the exercise will be added with no specified time.", closeButtonTitle: "Cancel")
        }
        else{
            if let minutes = minField.text{
                // MARK: new
                // new section for going to note page
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupNoteViewController") as! GroupNoteViewController
                SVC.sets = self.sets
                SVC.exercise = self.exercise
                SVC.reps = self.reps
                SVC.weight = "\(minutes)mins"
                self.navigationController?.pushViewController(SVC, animated: true)
                // end of going to note page section
                
                /*let dictData = ["exercise": self.exercise,
                                "sets": self.sets,
                                "reps": self.reps,
                                "minutes": "\(minutes)"
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}
