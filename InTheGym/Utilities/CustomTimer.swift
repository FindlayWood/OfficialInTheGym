//
//  CustomTimer.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//
// Timer class - starts a timer with a given time


import Foundation


class CustomTimer: NSObject {

    var timer = Timer()
    
    var seconds: Int
    
    // MARK: - Callbacks
    var timerEndedCallback: (()->())?
    var timerInProgressCallback: ((_ elapsedTime: Int)->())?
    
    // MARK: - Initializer
    init(seconds: Int) {
        self.seconds = seconds
    }
    
    func startTimer(timerEnded: @escaping () -> (), timerInProgress: @escaping (_ elapsedTime: Int)->()) {
        if !timer.isValid {
            timer = Timer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timerEndedCallback = timerEnded
            timerInProgressCallback = timerInProgress
        }
    }
    
    @objc func updateTimer() {
        if seconds > 0 {
            seconds -= 1
            timerInProgressCallback?(seconds)
        } else {
            timer.invalidate()
            timerEndedCallback?()
        }
    }
    
}
