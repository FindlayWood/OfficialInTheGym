//
//  File.swift
//  
//
//  Created by Findlay-Personal on 05/04/2023.
//

import Combine
import Foundation

class WelcomeViewModel: ObservableObject {
    
    var coordinator: LoginFlow?
    
    var title: String
    
    /// Whether the app supplied an example workout to open. Before signup there is nothing of the
    /// user's to show, so this is the one way to see what logging a workout is like.
    let canTryWorkout: Bool
    
    init(title: String, canTryWorkout: Bool = false) {
        self.title = title
        self.canTryWorkout = canTryWorkout
    }
    
    func signupAction() {
        coordinator?.presentSignup()
    }
    
    func loginAction() {
        coordinator?.presentLogin()
    }
    
    func tryWorkoutAction() {
        coordinator?.presentDemoWorkout()
    }
}
