//
//  AddGroupWorkoutTypeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddGroupWorkoutTypeViewController: UIViewController {

    weak var coordinator: AddGroupWorkoutCoordinator?
    
    var display = AddGroupWorkoutTypeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        view.backgroundColor = .white
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.darkColour
        navigationItem.title = "Add Workout"
    }
    
    func initDisplay() {
        display.newWorkoutButton.addTarget(self, action: #selector(newWorkoutSelected), for: .touchUpInside)
        display.savedWorkoutButton.addTarget(self, action: #selector(savedWorkoutSelected), for: .touchUpInside)
    }
    
    @objc func newWorkoutSelected() {
        coordinator?.addNewWorkout()
    }
    @objc func savedWorkoutSelected() {
        coordinator?.addSavedWorkout()
    }
}
