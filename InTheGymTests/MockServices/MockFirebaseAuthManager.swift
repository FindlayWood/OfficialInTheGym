//
//  MockFirebaseAuthManager.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 07/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
@testable import InTheGym

class MockFirebaseAuthManager: AuthManagerService {
    
    var completionResult: Result<Void,SignUpError> = .success(())
    var usernameCompletionResult: Bool = true
    
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Result<Void, SignUpError>) -> Void) {
        completion(completionResult)
    }
    
    func checkUsernameIsUnique(for username: String, completion: @escaping (Bool) -> ()) {
        completion(usernameCompletionResult)
    }
    
    func loginUser(with loginModel: LoginModel, completion: @escaping (Result<Users, loginError>) -> Void) {
        
    }
    
    // bad design - having to import Firebase
    func resendEmailVerification(to user: User, completion: @escaping (Bool) -> Void) {
        
    }
    
    func sendResetPassword(to email: String, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    
    
}

