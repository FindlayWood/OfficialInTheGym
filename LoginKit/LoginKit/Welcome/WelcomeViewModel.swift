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
    
    /// The feature cards to draw — only those the app supplied a way to open. Before signup there is
    /// nothing of the user's to show, so these are the one way to see what the app does.
    let features: [WelcomeFeature]
    
    init(title: String, features: [WelcomeFeature] = []) {
        self.title = title
        self.features = features
    }
    
    func signupAction() {
        coordinator?.presentSignup()
    }
    
    func loginAction() {
        coordinator?.presentLogin()
    }
    
    func open(_ feature: WelcomeFeature) {
        switch feature {
        case .training: coordinator?.presentDemoWorkout()
        case .stats: coordinator?.presentStatsPreview()
        case .performance: coordinator?.presentPerformancePreview()
        }
    }
}
