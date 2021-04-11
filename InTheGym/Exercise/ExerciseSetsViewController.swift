//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/09/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// this page is not for saved workouts
// it is for the new implementation of sets page
// it asks the user for how many sets on an exercise
// and then passes onto the new implementation of reps page

import UIKit
import SCLAlertView

class ExerciseSetsViewController: UIViewController {
    
    // textfield to enter sets
    @IBOutlet weak var text:UITextField!
    
    // switch for deciding if reps vary or not
    @IBOutlet var onoff: UISwitch!
    
    // bool variable for if reps vary
    var varyReps : Bool = false
    
    // variables from previous page, body type/exercise name
    var exercise: String = ""
    var type: String = "weights"
    
    @IBAction func nextTapped(_ sender:UIButton){
        if text.text == ""{
            showError()
        }else{
            let completedArray = Array(repeating: false, count: Int(text.text!)!)
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destVC = Storyboard.instantiateViewController(withIdentifier: "NewRepsViewController") as! NewRepsViewController
            destVC.varyReps = self.varyReps
            destVC.sets = self.text.text!
            destVC.exercise = self.exercise
            destVC.type = self.type
            destVC.completedArray = completedArray
            self.navigationController?.pushViewController(destVC, animated: true)
            //self.present(destVC, animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sets"
        
        text.layer.borderColor = UIColor.white.cgColor
        text.layer.borderWidth = 4
        text.layer.cornerRadius = 6
        text.keyboardType = .numberPad
        text.becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        
        onoff.isOn = false
        
        onoff.addTarget(self, action: #selector(stateChanged), for: .valueChanged)

    }
    
    @objc func stateChanged(switchState: UISwitch){
        if onoff.isOn {
            varyReps = true
        } else {
            varyReps = false
        }
    }
    
    func showError(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("Enter a Set Amount!", subTitle: "You have not entered a number for the sets for this exercise. To enter a number tap on the big dark blue box. You must enter a set number to continue.", closeButtonTitle: "Ok")
    }

}
