//
//  NoteViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/09/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class NoteViewController: UIViewController {
    
    // variables passed from the previous page
    var sets: String = ""
    var exerciseName: String = ""
    var reps: String = ""
    var weight: String = ""
    var type: String = ""
    
    var variedReps:Bool!
    var repArray = [String]()
    var completedArray : [Bool] = []
    
    
    var placeHolder : String = "enter a note for the player to view..."
    
    @IBOutlet weak var note:UITextView!
    
    @IBAction func finished(_ sender:UIButton){
        let noteText = note.text
        var dictData : [String: AnyObject] = [:]
        var exerciseToAdd : exercise!
        if noteText == placeHolder{
            
            if variedReps{
                dictData = ["exercise": self.exerciseName,
                                "type": self.type,
                                "sets": self.sets,
                                "reps": self.repArray,
                                "weight": self.weight,
                                "completedSets":self.completedArray] as [String:AnyObject]
                exerciseToAdd = exercise(exercises: dictData)
                
            }else{
                dictData = ["exercise": self.exerciseName,
                                "type": self.type,
                                "sets": self.sets,
                                "reps": self.reps,
                                "weight": self.weight,
                                "completedSets":self.completedArray] as [String:AnyObject]
                exerciseToAdd = exercise(exercises: dictData)
                
            }
            
            
        }
        else{
            if variedReps{
                dictData = ["exercise": self.exerciseName,
                                "type": self.type,
                                "sets": self.sets,
                                "reps": self.repArray,
                                "weight": self.weight,
                                "note": noteText!,
                                "completedSets":self.completedArray] as [String:AnyObject]
                exerciseToAdd = exercise(exercises: dictData)
                
            }else{
                dictData = ["exercise": self.exerciseName,
                                "type": self.type,
                                "sets": self.sets,
                                "reps": self.reps,
                                "weight": self.weight,
                                "note": noteText!,
                                "completedSets":self.completedArray] as [String:AnyObject]
                exerciseToAdd = exercise(exercises: dictData)
                
            }
            
            
        }
        
        AddWorkoutHomeViewController.exercises.append(dictData)
        
        DisplayTopView.displayTopView(with: "Exercise added.", on: self)
//        let alert = SCLAlertView()
//        alert.showSuccess("Added!", subTitle: "Exercise has been added to the list.", closeButtonTitle: "ok")
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 7], animated: true)
        
        
    }
    
    @IBAction func skip(_ sender:UIButton){
        var dictData : [String:AnyObject] = [:]
        var exerciseToAdd : exercise!
        if variedReps{
            dictData = ["exercise": self.exerciseName,
                        "type": self.type,
                        "sets": self.sets,
                        "reps": self.repArray,
                        "weight": self.weight,
                        "completedSets":self.completedArray] as [String:AnyObject]
            exerciseToAdd = exercise(exercises: dictData)
            
        }else{
            dictData = ["exercise": self.exerciseName,
                        "type": self.type,
                        "sets": self.sets,
                        "reps": self.reps,
                        "weight": self.weight,
                        "completedSets":self.completedArray] as [String:AnyObject]
            exerciseToAdd = exercise(exercises: dictData)
            
        }
        
        
        AddWorkoutHomeViewController.exercises.append(dictData)
        
        DisplayTopView.displayTopView(with: "Exercise added.", on: self)

        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 7], animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        note.textContainer.maximumNumberOfLines = 5
        note.textContainer.lineBreakMode = .byTruncatingTail
        note.isScrollEnabled = false
        note.layer.cornerRadius = 8
        
        note.text = placeHolder
        note.textColor = .lightGray
        note.delegate = self
        note.tintColor = Constants.lightColour
        hideKeyboardWhenTappedAround()
    }
    
    // the two below funstions are for having a placeholder in the note box
    // there is no placeholder for a textview
    // therefor functions needed to set light gray text initial to appear as placeholder
    // then change text to black when user begins typing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if note.textColor == UIColor.lightGray {
            note.text = nil
            note.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if note.text.isEmpty {
            note.text = placeHolder
            note.textColor = UIColor.lightGray
        }
    }
}
