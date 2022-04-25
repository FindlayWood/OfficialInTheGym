//
//  AddWorkoutSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddWorkoutSelectionViewController: UIViewController, Storyboarded {
    
    // MARK: - Coordinator
    var coordinator: WorkoutsFlow?
    
    // MARK: - Outlets
    @IBOutlet weak var liveAddButton: UIButton!
    @IBOutlet weak var regularAddButton: UIButton!
    @IBOutlet weak var savedWorkoutButton: UIButton!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add a Workout"
        liveAddButton.addViewShadow(with: .darkColour)
        regularAddButton.addViewShadow(with: .darkColour)
        savedWorkoutButton.addViewShadow(with: .darkColour)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Live Action
    @IBAction func liveAddWorkout(_ sender:UIButton){
        coordinator?.addLiveWorkout()
    }
    
    // MARK: - Regular Action
    @IBAction func addWorkout(_ sender:UIButton){
        coordinator?.addNewWorkout(UserDefaults.currentUser)
    }
    
    // MARK: - Saved Action
    @IBAction func savedWorkout(_ sender: UIButton) {
         coordinator?.addSavedWorkout()
    }
}
