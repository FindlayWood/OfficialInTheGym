//
//  AddWorkoutSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddWorkoutSelectionViewController: UIViewController, Storyboarded {
    
    var coordinator: WorkoutsFlow?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add a Workout"

    }
    
    @IBAction func liveAddWorkout(_ sender:UIButton){
        
        coordinator?.addLiveWorkout()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let workoutPage = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
//        workoutPage.liveAdd = true
//        workoutPage.fromDiscover = false
//        navigationController?.pushViewController(workoutPage, animated: true)
    }
    
    
    @IBAction func addWorkout(_ sender:UIButton){
        coordinator?.regularWorkout()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextVC = storyboard.instantiateViewController(withIdentifier: "AddWorkoutHomeViewController") as! AddWorkoutHomeViewController
//        nextVC.playerBool = true
//        nextVC.hidesBottomBarWhenPushed = true
//        AddWorkoutHomeViewController.groupBool = false
//        navigationController?.pushViewController(nextVC, animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
