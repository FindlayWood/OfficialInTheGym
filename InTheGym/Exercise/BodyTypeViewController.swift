//
//  BodyTypeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// coaches page
// select body type of exercise

import UIKit

class BodyTypeViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CreationDelegate?
    var newExercise: exercise?
    
    var fromLiveWorkout:Bool!
    var workoutID:String!
    @IBOutlet weak var circuitButton:UIButton!
    @IBOutlet weak var amrapButton: UIButton!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    @IBAction func buttonTapped(_ sender:UIButton){
        sender.pulsate()
        guard let newExercise = newExercise else {return}
        switch sender.titleLabel?.text{
        case "Upper Body":
            newExercise.type = .UB
            coordinator?.bodyTypeSelected(newExercise)
        case "Lower Body":
            newExercise.type = .LB
            coordinator?.bodyTypeSelected(newExercise)
        case "Core":
            newExercise.type = .CO
            coordinator?.bodyTypeSelected(newExercise)
        case "Cardio":
            newExercise.type = .CA
            coordinator?.bodyTypeSelected(newExercise)
        default:
            newExercise.type = .CU
            coordinator?.bodyTypeSelected(newExercise)
        }
    }
    
    @IBAction func circuitTapped(_ sender:UIButton) {
        let coordinator = coordinator as? RegularWorkoutFlow
        coordinator?.addCircuit()
    }
    
    @IBAction func amrapTapped(_ sender: UIButton) {
        let coordinator = coordinator as? RegularWorkoutFlow
        coordinator?.addAMRAP()
    }
    
    @IBAction func otherTapped(_ sender: UIButton) {
        guard let newExercise = newExercise else {return}
        coordinator?.otherSelected(newExercise)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Body Type"
        if fromLiveWorkout == true{
            pageNumberLabel.text = "1 of 2"
            self.circuitButton.isHidden = true
        }else{
            pageNumberLabel.text = "1 of 6"
        }
        if let _ = coordinator as? CircuitCoordinator {
            self.circuitButton.isHidden = true
        }
        switch coordinator{
        case is RegularWorkoutCoordinator:
            pageNumberLabel.text = "1 of 6"
        case is CircuitCoordinator:
            pageNumberLabel.text = "1 of 5"
            self.circuitButton.isHidden = true
            self.amrapButton.isHidden = true
        case is LiveWorkoutCoordinator:
            pageNumberLabel.text = "1 of 2"
            self.circuitButton.isHidden = true
            self.amrapButton.isHidden = true
        case is AMRAPCoordinator:
            pageNumberLabel.text = "1 of 4"
            self.circuitButton.isHidden = true
            self.amrapButton.isHidden = true
        default:
             break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
