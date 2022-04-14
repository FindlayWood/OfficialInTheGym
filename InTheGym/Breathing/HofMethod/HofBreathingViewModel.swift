//
//  HofBreathingViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class HofBreathingViewModel {
    
    // MARK: - Publishers
    @Published var roundsComplete: Int = 0
    @Published var stage: BreathingStage = .breatheIn
    @Published var holdingTime: Int!
    @Published var hideTimeLabel: Bool = true
    @Published var fullBreath: BreathingStage!
    @Published var completed: Bool = false
    
    // MARK: - Properties
    var navigationTitle: String = "Breath Work"
    
    private var subscriptions = Set<AnyCancellable>()
    
    var mainTimer: AnyCancellable!
    
    var holdTimer: AnyCancellable!
    
    var shortHoldTimer: AnyCancellable!
    
    var rounds: Int = 0
    
    var holdingTimes: [Int] = [60, 60, 90, 90, 120]
    
    var mainHoldingTime: Int = 60
    
    var shortHoldTime: Int = 15

    var breatheIn: Bool = true {
        didSet {
            stage = breatheIn ? .breatheIn : .breatheOut
        }
    }
    
    // MARK: - Actions
    func start() {
        mainTimer = Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .prepend()
            .sink { [weak self] _ in
                guard let self = self else {return}
                if self.rounds < 60 || self.breatheIn {
                    self.rounds += 1
                    self.breatheIn.toggle()
                } else {
                    self.hold(for: self.holdingTimes[self.roundsComplete])
                    self.rounds = 0
                }
                if self.rounds == 60 || self.rounds == 61 {
                    self.hideTimeLabel = false
                    self.fullBreath = self.breatheIn ? .breatheIn : .breatheOut
                }
            }
    }
    
    func hold(for seconds: Int) {
        mainTimer.cancel()
        stage = .hold
        hideTimeLabel = false
        holdingTime = seconds
        var time = seconds
        holdTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {return}
                if time > 0 {
                    time -= 1
                    self.holdingTime = time
                } else {
                    self.stageThree()
                    self.hideTimeLabel = true
                }
            }
    }
    
    func stageThree() {
        holdTimer.cancel()
        // breath in for 2
        self.stage = .breatheIn
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // hold
            self.hideTimeLabel = false
            self.holdingTime = self.shortHoldTime
            self.stage = .hold
            self.shortHoldTimer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else {return}
                    if self.shortHoldTime > 0 {
                        self.shortHoldTime -= 1
                        self.holdingTime = self.shortHoldTime
                    } else {
                        self.hideTimeLabel = true
                        self.roundComplete()
                    }
                }
        }
        // hold 15 seconds
    }
    
    func roundComplete() {
        shortHoldTimer.cancel()
        
        self.stage = .breatheOut
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.roundsComplete < 4 {
                //continue to another round
                self.hideTimeLabel = false
                self.roundsComplete += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.restart()
                }
            } else {
                self.breathingCompleted()
            }
        }
    }
    
    func restart() {
        hideTimeLabel = true
        mainHoldingTime = 60
        shortHoldTime = 15
        breatheIn = true
        start()
    }
    
    func breathingCompleted() {
        completed = true
    }
    
    // MARK: - Functions
}

enum BreathingStage {
    case ready
    case breatheIn
    case breatheOut
    case hold
}
