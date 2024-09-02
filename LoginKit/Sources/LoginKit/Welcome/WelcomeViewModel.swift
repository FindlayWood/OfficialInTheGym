//
//  File.swift
//  
//
//  Created by Findlay-Personal on 05/04/2023.
//

import Foundation

class WelcomeViewModel: ObservableObject {
    
    var coordinator: LoginFlow?
    
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func signupAction() {
        coordinator?.presentSignup()
    }
    
    func loginAction() {
        coordinator?.presentLogin()
    }
}
