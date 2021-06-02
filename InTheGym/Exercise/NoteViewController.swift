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

class NoteViewController: UIViewController, Storyboarded, UITextViewDelegate {
    
    weak var coordinator: RegularWorkoutFlow?
    var newExercise: exercise?
    
    var placeHolder : String = "enter a note for the player to view..."
    
    @IBOutlet weak var note:UITextView!
    
    @IBAction func finished(_ sender:UIButton) {
        let noteText = note.text
        if noteText == placeHolder {
            
            guard let newExercise = newExercise else {return}
            coordinator?.noteAdded(newExercise)
        } else {
            guard let newExercise = newExercise else {return}
            newExercise.note = noteText
            coordinator?.noteAdded(newExercise)
        }
        
        DisplayTopView.displayTopView(with: "Exercise added.", on: self)
    }
    
    @IBAction func skip(_ sender:UIButton) {
        guard let newExercise = newExercise else {return}
        coordinator?.noteAdded(newExercise)
        DisplayTopView.displayTopView(with: "Exercise added.", on: self)
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
