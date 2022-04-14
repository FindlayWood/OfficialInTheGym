//
//  BoxBreathingViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class BoxBreathingViewModel {
    
    // MARK: - Publishers
    @Published var currentStage: Node<BreathingStage>!
    
    // MARK: - Properties
    var navigationTitle: String = "Box Breathing"
    
    var mainTimer: AnyCancellable!
    
    var seconds: Int = 60
    
    var stages: CircularLinkedList<BreathingStage> = CircularLinkedList<BreathingStage>([.breatheIn, .hold, .breatheOut, .hold])
    
    // MARK: - Actions
    func start() {
        currentStage = stages.head
        mainTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {return}
                if self.seconds > 0 {
                    self.seconds -= 1
                    if self.seconds % 5 == 0 {
                        // change
                        self.currentStage = self.currentStage.next
                    }
                }
            }
    }
    
    // MARK: - Functions
}
