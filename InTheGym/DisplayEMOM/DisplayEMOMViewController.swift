//
//  DisplayEMOMViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class DisplayEMOMViewController: UIViewController {
    
    var mainTimer = Timer()
    
    var minuteTimer = Timer()
    
    var display = DisplayEMOMView()
    
    var viewModel = DisplayEMOMViewModel()
    
    var emom: EMOM!
    
    var workout: workout! /// workout containing the emom
    
    var position: Int! /// the position of the emom in the workout
    
    var exerciseIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initViewModel()
        initDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "EMOM"
    }

    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTimerPressed(_:)))
        navigationItem.rightBarButtonItem = barButton
    }
    
    func initViewModel() {
        
        viewModel.updateMainTimerClosure = { [weak self] (newTime) in
            guard let self = self else {return}
            guard let fullTime = self.emom.timeLimit else {return}
            let progress = CGFloat(CGFloat(newTime) / CGFloat(fullTime))
            self.display.fullTimePrgoressView.progress = progress
            self.display.fullTimePrgoressView.timeRemaining = newTime
            // TODO: - update display main timer
            // TODO: - get full amount of time to calculate progress
            
        }
        
        viewModel.updateMinuteTimerClosure = { [weak self] (newTime) in
            guard let self = self else {return}
            let progress = CGFloat(CGFloat(newTime) / CGFloat(60))
            self.display.minuteProgressView.progress = progress
            self.display.minuteProgressView.timeRemaining = newTime
            // TODO: - update display minute timer
        }
        
        viewModel.mainTimerCompleted = { [weak self] in
            guard let self = self else {return}
            self.viewModel.emomCompleted()
            self.navigationItem.hidesBackButton = false
            let alert = SCLAlertView()
            let rpe = alert.addTextField()
            rpe.placeholder = "enter rpe 1-10..."
            rpe.keyboardType = .numberPad
            rpe.becomeFirstResponder()
            alert.addButton("Save") {
                guard let score = rpe.text else {return}
                guard let scoreInt = Int(score) else {return}
                self.viewModel.rpeScoreGiven(scoreInt)
            }
            alert.showSuccess("RPE", subTitle: "Enter RPE for EMOM(1-10).",closeButtonTitle: "cancel")
        }
        
        viewModel.minuteCompleted = { [weak self] in
            guard let self = self else {return}
            let numberOfExercises = self.viewModel.emomModel.exercises.count
            let exercises = self.viewModel.emomModel.exercises
            let completedPosition = self.exerciseIndex % numberOfExercises
            let exerciseName = exercises[completedPosition].exercise
            let exerciseReps = exercises[completedPosition].reps[0]
            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exerciseName, reps: exerciseReps, weight: nil)
            
            self.exerciseIndex += 1
            let position = self.exerciseIndex % numberOfExercises
            self.display.exerciseView.configure(with: exercises[position])
            self.completedMinute()
            
        }
        
        let fullTime = viewModel.emomModel.timeLimit
        viewModel.mainTimerVariable = fullTime
        viewModel.workout = workout
        viewModel.position = position
    }
    
    func initDisplay() {
//        if emom.started ?? false {
//            // TODO: - Calculate start time
//            navigationItem.rightBarButtonItem?.isEnabled = false
//        }
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.emomModel.completed
        let exerciseOne = viewModel.emomModel.exercises[exerciseIndex]
        display.exerciseView.configure(with: exerciseOne)
        display.initialMainTime.text = viewModel.emomModel.timeLimit.convertToTime()
        display.initialMinuteTime.text = 60.convertToTime()
    }
    
    @objc func startTimerPressed(_ sender: UIButton) {
        navigationItem.hidesBackButton = true
        viewModel.startTimers()
        display.initialMainTime.removeFromSuperview()
        display.initialMinuteTime.removeFromSuperview()
        emom.started = true
        viewModel.startEMOM()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

extension DisplayEMOMViewController {
    func completedMinute() {
        UIView.animate(withDuration: 0.6) {
            self.display.backgroundColor = .lightColour
        } completion: { _ in
            UIView.animate(withDuration: 0.6) {
                self.display.backgroundColor = .white
            }
        }
    }
}
