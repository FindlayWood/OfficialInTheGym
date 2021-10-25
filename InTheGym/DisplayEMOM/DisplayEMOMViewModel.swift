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
    var mainTimerCompleted:(()->())?
    var minuteCompleted:(()->())?
    
    // MARK: - Timers
    var mainTimer = Timer()
    var minuteTimer = Timer()
    
    // MARK: - Timer Variables
    var minuteTimerVariable = 60
    var mainTimerVariable = 600
    
    func startTimers() {
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
        //minuteTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMinuteTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateMainTimer() {
        if mainTimerVariable > 0 {
            mainTimerVariable -= 1
            updateMainTimerClosure?(mainTimerVariable)
        } else {
            mainTimer.invalidate()
            //minuteTimer.invalidate()
            mainTimerCompleted?()
        }
        
        if minuteTimerVariable > 0 {
            minuteTimerVariable -= 1
            updateMinuteTimerClosure?(minuteTimerVariable)
        } else if minuteTimerVariable == 0 {
            minuteTimerVariable = 59
            updateMinuteTimerClosure?(minuteTimerVariable)
            minuteCompleted?()
        }
    }
    
//    @objc func updateMinuteTimer() {
//        if minuteTimerVariable > 0 {
//            minuteTimerVariable -= 1
//            updateMinuteTimerClosure?(minuteTimerVariable)
//        } else if minuteTimerVariable == 0 {
//            minuteTimerVariable = 59
//            updateMinuteTimerClosure?(minuteTimerVariable)
//            minuteCompleted?()
//        }
//    }
    
    // MARK: - Starting EMOM
    func startEMOM() {
        // TODO: - Update Firebase started emom time
    }
}
