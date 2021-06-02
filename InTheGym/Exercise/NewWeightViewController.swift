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

class NewWeightViewController: UIViewController, Storyboarded {
    
    weak var coordinator: RegularAndLiveFlow?
    var newExercise: exercise?
    
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
            
            guard let newExercise = newExercise else {return}
            if coordinator is LiveWorkoutCoordinator {
                newExercise.weightArray?.append("MAX")
            } else {
                newExercise.weight = "MAX"
            }
            coordinator?.weightSelected(newExercise)

        }
        else if text.text == ""{
            showEmptyAlert()
        }else{
            
            let m = measurement.text!
            let t = text.text!
            guard let newExercise = newExercise else {return}
            if coordinator is LiveWorkoutCoordinator {
                newExercise.weightArray?.append("\(t)\(m)")
            } else {
                newExercise.weight = "\(t)\(m)"
            }
            coordinator?.weightSelected(newExercise)
            
        }
        
    }
    
    @IBAction func skipPressed(_ sender:UIButton) {
        
        guard let newExercise = newExercise else {return}
        if coordinator is LiveWorkoutCoordinator {
            newExercise.weightArray?.append("")
        }
        coordinator?.weightSelected(newExercise)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isHidden = true
        text.keyboardType = .decimalPad
        text.tintColor = .white
        measurement.isUserInteractionEnabled = false
        hideKeyboardWhenTappedAround()
        shadowButtons()
        
        switch coordinator{
        case is RegularWorkoutCoordinator:
            pageNumberLabel.text = "5 of 6"
        case is LiveWorkoutCoordinator:
            pageNumberLabel.text = "2 of 2"
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Weight"
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.darkColour
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
