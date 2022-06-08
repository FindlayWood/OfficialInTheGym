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
    
    // MARK: - Properties
    var mainTimer = Timer()
    
    var minuteTimer = Timer()
    
    var display = DisplayEMOMView()
    
    var viewModel = DisplayEMOMViewModel()
    
    var emom: EMOM!

    // MARK: - View
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
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isStartButtonEnabled()
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.updateMainTimerClosure = { [weak self] (newTime) in
            guard let self = self else {return}
            let fullTime = self.viewModel.emomModel.timeLimit
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
            self.showRPEEMOM(completion: self.viewModel.rpeScoreGiven(_:))
        }
        
        viewModel.minuteCompleted = { [weak self] in
            guard let self = self else {return}
            let numberOfExercises = self.viewModel.emomModel.exercises.count
            let exercises = self.viewModel.emomModel.exercises
            let completedPosition = self.viewModel.exerciseIndex % numberOfExercises
            let exerciseName = exercises[completedPosition].exercise
            let exerciseReps = exercises[completedPosition].reps?[0]
            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exerciseName, reps: exerciseReps ?? 0, weight: nil)
            
            self.viewModel.exerciseIndex += 1
            let position = self.viewModel.exerciseIndex % numberOfExercises
            self.display.exerciseView.configure(with: exercises[position])
            self.completedMinute()
        }
        viewModel.connectionError = { [weak self] in
            guard let self = self else {return}
            self.displayTopMessage(with: "Connection Error!")
        }
        
        let fullTime = viewModel.emomModel.timeLimit
        viewModel.mainTimerVariable = fullTime
    }
    
    func initDisplay() {
//        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.emomModel.completed
        let exerciseOne = viewModel.emomModel.exercises[viewModel.exerciseIndex]
        display.exerciseView.configure(with: exerciseOne)
        display.initialMainTime.text = viewModel.emomModel.timeLimit.convertToTime()
        display.initialMinuteTime.text = 60.convertToTime()
    }
    
    // MARK: - Actions
    @objc func startTimerPressed(_ sender: UIButton) {
        navigationItem.hidesBackButton = true
        viewModel.startTimers()
        display.initialMainTime.removeFromSuperview()
        display.initialMinuteTime.removeFromSuperview()
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
