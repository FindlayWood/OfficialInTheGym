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
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    @IBAction func buttonTapped(_ sender:UIButton){
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "ExerciseViewController") as! ExerciseViewController
        SVC.fromLiveWorkout = self.fromLiveWorkout
        SVC.exerciseType = sender.titleLabel!.text as! String
        SVC.workoutID = self.workoutID
        guard var newExercise = newExercise else {return}
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
            newExercise.type = .UB
            coordinator?.bodyTypeSelected(newExercise)
        }
        
        //self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    @IBAction func circuitTapped(_ sender:UIButton) {
        let coordinator = coordinator as? RegularWorkoutFlow
        coordinator?.addCircuit()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextVC = storyboard.instantiateViewController(withIdentifier: "CreateCircuitViewController") as! CreateCircuitViewController
//        self.navigationController?.pushViewController(nextVC, animated: true)
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
            pageNumberLabel.text = "1 of 4"
            self.circuitButton.isHidden = true
        case is LiveWorkoutCoordinator:
            pageNumberLabel.text = "1 of 2"
            self.circuitButton.isHidden = true
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
