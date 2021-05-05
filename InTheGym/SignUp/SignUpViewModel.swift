//
//  SignUpViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase


enum SignUpValidationState {
    case Valid
    case InValid(SignUpError)
}
enum SignUpError {
    case fillAllFields
    case invalidEmail
    case emailTaken
    case takenUsername
    case passwordsDoNotMatch
    case passwordTooShort
    case unknown
}

class SignUpViewModel {
    var SignUpSuccesfulClosure:((String)->())?
    var SignUpFailedClosure:((SignUpError)->())?
    private var minimumPasswordLength = 6
    private var user = SignUpUserModel()
    let haptic = UINotificationFeedbackGenerator()
    
    var email : String {
        return user.email
    }
    var username : String {
        return user.username
    }
    var firstName : String {
        return user.firstName
    }
    var lastName : String {
        return user.lastName
    }
    var password : String {
        return user.password
    }
    var confirmPassword : String {
        return user.confirmPassword
    }
    var admin : Bool {
        return user.admin
    }
    
    //MARK: - Checking username is unique
    func checkUsernameIsUnique(for username:String, completion: @escaping (Bool) -> ()) {
        let ref = Database.database().reference().child("Usernames").child(username)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    //MARK: - Checking all fields are valid
    func loginAttempt() {
        switch validate(){
        case .InValid(let errorMessage):
            print(errorMessage)
            self.SignUpFailedClosure?(errorMessage)
        case .Valid:
            checkUsernameIsUnique(for: user.username) { (unique) in
                if unique {
                    self.tryToSignUp()
                } else {
                    self.SignUpFailedClosure?(.takenUsername)
                }
            }
        }
    }
    
    func tryToSignUp() {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { (signedUpUser, error) in
            if let error = error {
                let error = error as NSError
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self.SignUpFailedClosure?(.emailTaken)
                case AuthErrorCode.invalidEmail.rawValue:
                    self.SignUpFailedClosure?(.invalidEmail)
                case AuthErrorCode.weakPassword.rawValue:
                    self.SignUpFailedClosure?(.passwordTooShort)
                default:
                    self.SignUpFailedClosure?(.unknown)
                    print("unknown error \(error.localizedDescription)")
                }
            } else {
                //succes
                self.haptic.prepare()
                
                let userID = Auth.auth().currentUser!.uid
                let user = Auth.auth().currentUser!
                
                user.sendEmailVerification()
                
                let userData = ["email":self.user.email,
                                "username":self.user.username,
                                "admin":self.user.admin!,
                                "firstName":self.user.firstName,
                                "lastName":self.user.lastName,
                                "uid":userID] as [String : Any]
                
                let userRef = Database.database().reference().child("users").child(userID)
                userRef.setValue(userData)
                
                let actData = ["time":ServerValue.timestamp(),
                               "message":"\(self.user.username), welcome to InTheGym!",
                               "type":"Account Created",
                               "posterID":userID,
                               "isPrivate":true] as [String:AnyObject]
                
                let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(userID)
                let postRef = Database.database().reference().child("Posts").childByAutoId()
                let postKey = postRef.key!
                let timelineRef = Database.database().reference().child("Timeline").child(userID)
                let usernamesRef = Database.database().reference().child("Usernames")
            
                postRef.setValue(actData)
                postSelfReferences.child(postKey).setValue(true)
                timelineRef.child(postKey).setValue(true)
                usernamesRef.child(self.user.username).setValue(true)
                FirebaseAPI.shared().uploadActivity(with: .AccountCreated)
                
                self.haptic.notificationOccurred(.success)
                self.SignUpSuccesfulClosure?(self.user.email)
            }
        }
    }
    
    
    
}

// MARK: - Update user attributes
extension SignUpViewModel {
    func updateEmail(with email:String) {
        user.email = email
    }
    func updateFirstName(with name:String) {
        user.firstName = name
    }
    func updateLastName(with name:String) {
        user.lastName = name
    }
    func updateUsername(with username:String) {
        user.username = username
    }
    func updatePassword(with password:String) {
        user.password = password
    }
    func updateConfirmPassword(with password:String) {
        user.confirmPassword = password
    }
    func updateAdmin(with admin:Bool) {
        user.admin = admin
    }
}

//MARK: - Validate Sign Up Attempt
extension SignUpViewModel {
    func validate() -> SignUpValidationState {
        if user.email.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty || user.username.isEmpty || user.password.isEmpty || user.confirmPassword.isEmpty{
            return .InValid(.fillAllFields)
        }
        if user.password.count < minimumPasswordLength || user.confirmPassword.count < minimumPasswordLength {
            return .InValid(.passwordTooShort)
        }
        if user.password != user.confirmPassword {
            return .InValid(.passwordsDoNotMatch)
        }
        return .Valid
    }
}
