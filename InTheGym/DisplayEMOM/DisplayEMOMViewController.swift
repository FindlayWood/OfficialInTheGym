//
//  DisplayEMOMViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayEMOMViewController: UIViewController {
    
    var mainTimer = Timer()
    
    var minuteTimer = Timer()
    
    var display = DisplayEMOMView()
    
    var viewModel = DisplayEMOMViewModel()
    
    var emom: EMOM!
    
    var workout: workout! // workout containing the emom
    
    var exerciseIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initViewModel()
        initDisplay()
        //display.updateFullTime()
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
        
        guard let fullTime = emom.timeLimit else {return}
        viewModel.mainTimerVariable = fullTime
//        display.fullTimePrgoressView.progress = 1
//        display.fullTimePrgoressView.timeRemaining = fullTime
//        display.minuteProgressView.progress = 1
//        display.minuteProgressView.timeRemaining = 60
    }
    
    func initDisplay() {
        if emom.started ?? false {
            // TODO: - Calculate start time
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        guard let exerciseOne = emom.exercises?[exerciseIndex] else {return}
        display.exerciseView.configure(with: exerciseOne)
    }
    
    @objc func startTimerPressed(_ sender: UIButton) {
        viewModel.startTimers()
        emom.started = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
}
