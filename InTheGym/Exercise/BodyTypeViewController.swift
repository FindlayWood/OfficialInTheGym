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
        
//        switch sender.titleLabel?.text{
//        case "Upper Body":
//            coordinator?.bodyTypeSelected(.UB)
//        case "Lower Body":
//            coordinator?.bodyTypeSelected(.LB)
//        case "Core":
//            coordinator?.bodyTypeSelected(.CO)
//        case "Cardio":
//            coordinator?.bodyTypeSelected(.CA)
//        default:
//            coordinator?.bodyTypeSelected(.UB)
//        }
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    @IBAction func circuitTapped(_ sender:UIButton) {
//        let coordinator = coordinator as? RegularWorkoutFlow
//        coordinator?.addCircuit()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "CreateCircuitViewController") as! CreateCircuitViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
