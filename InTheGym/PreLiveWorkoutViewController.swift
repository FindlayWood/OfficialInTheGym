//
//  PreLiveWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class PreLiveWorkoutViewController: UIViewController, Storyboarded {
    
    weak var coordinator: WorkoutsCoordinator?
    
    @IBOutlet weak var titlefield:UITextField!
    
    let userID = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        titlefield.delegate = self
        titlefield.tintColor = Constants.darkColour
        titlefield.returnKeyType = .done
        navigationItem.title = "Live Workout Title"
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func continuePressed(_ sender:UIButton){

        
        if titlefield.text?.trimmingCharacters(in: .whitespaces) == ""{
            let alert = SCLAlertView()
            alert.showError("Enter a title!", subTitle: "You must enter a title to begin the workout. The title can be anything you want.")
        }else{

            let workoutRef = Database.database().reference().child("Workouts").child(self.userID).childByAutoId()
            let workoutID = workoutRef.key!
            let workoutTitle = titlefield.text!
            let workoutData = ["completed":false,
                               "createdBy":ViewController.username!,
                               "title":workoutTitle,
                               "startTime":Date.timeIntervalSinceReferenceDate,
                               "liveWorkout": true,
                               "creatorID":self.userID,
                               "workoutID":workoutID,
                               "fromDiscover":false,
                               "assigned":false] as [String : AnyObject]
            workoutRef.setValue(workoutData)
            guard let workoutModel = liveWorkout(data: workoutData) else {return}
            coordinator?.startLiveWorkout(workoutModel)
//            let vc = DisplayWorkoutViewController.instantiate()
//            vc.selectedWorkout = workoutModel
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc, animated: true)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let workoutPage = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
//            workoutPage.liveAdd = true
//            workoutPage.fromDiscover = false
//            workoutPage.workoutID = workoutID
//            workoutPage.titleString = workoutTitle
//            workoutPage.playerID = self.userID
//            workoutPage.username = ViewController.username
//            workoutPage.creatorUsername = ViewController.username
//            workoutPage.creatorID = self.userID
//            workoutPage.hidesBottomBarWhenPushed = true
//            WorkoutDetailViewController.exercises.removeAll()
//            titlefield.text = ""
//            navigationController?.pushViewController(workoutPage, animated: true)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespaces) != ""{
            print("move to next with title = \(textField.text!)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
