//
//  DisplayEMOMViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class DisplayEMOMViewModel {
    // MARK: - Callbacks
    var updateMainTimerClosure:((Int)->())?
    var updateMinuteTimerClosure:((Int)->())?
    var minuteTimerFinished:(()->())?
    
    // MARK: - Timers
    var mainTimer = Timer()
    var minuteTimer = Timer()
    
    // MARK: - Timer Variables
    var minuteTimerVariable = 60
    var mainTimerVariable = 600
    
    func startTimers() {
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
        minuteTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMinuteTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateMainTimer() {
        if mainTimerVariable > 0 {
            mainTimerVariable -= 1
            updateMainTimerClosure?(mainTimerVariable)
        } else {
            mainTimer.invalidate()
            minuteTimer.invalidate()
        }
    }
    
    @objc func updateMinuteTimer() {
        if minuteTimerVariable > 0 {
            minuteTimerVariable -= 1
            updateMinuteTimerClosure?(minuteTimerVariable)
        } else if minuteTimerVariable == 0 {
            minuteTimerVariable = 59
            updateMinuteTimerClosure?(minuteTimerVariable)
        }
    }
    
    // MARK: - Main Timer
    func startMainTimer() {
        let mainTimer = CustomTimer(seconds: mainTimerVariable)
        mainTimer.startTimer {
            //TODO: timer has ended
        } timerInProgress: { [weak self] elapsedTime in
            guard let self = self else {return}
            self.updateMainTimerClosure?(elapsedTime)
        }
    }
    
    func startMinuteTimer() {
        let minuteTimer = CustomTimer(seconds: 60)
        minuteTimer.startTimer { [weak self] in
            guard let self = self else {return}
            self.minuteTimerFinished?()
        } timerInProgress: { [weak self] elapsedTime in
            guard let self = self else {return}
            self.updateMinuteTimerClosure?(elapsedTime)
        }
    }
    
    // MARK: - Starting EMOM
    func startEMOM() {
        // TODO: - Update Firebase started emom time
    }
}
