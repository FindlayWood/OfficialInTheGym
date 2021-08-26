//
//  SignUpUser.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpUserViewModel:NSObject {
    // this class takes a user and signs them up to the firebase database
    
    // user to sign up
    var user : Users!
    var password : String = String()
    
    var userRef:DatabaseReference!
    var usernameRef:DatabaseReference!
    
    let haptic = UINotificationFeedbackGenerator()
    
    private(set) var userCreated : Bool!{
        didSet{
            self.bindSignUpViewModelToController()
        }
    }
    
    var bindSignUpViewModelToController : (() -> ()) = {}
    
    init(this user:Users, with password:String) {
        self.user = user
        self.password = password
        super.init()
        userRef = Database.database().reference().child("users")
        usernameRef = Database.database().reference().child("Usernames")
        signUp()
        
    }
    
    func signUp(){
        // create new user
        Auth.auth().createUser(withEmail: user.email, password: password) { (user, error) in
            if error == nil{
                self.haptic.prepare()
                
                // create new user tokens
                let userID = Auth.auth().currentUser!.uid
                let user = Auth.auth().currentUser!
                
                user.sendEmailVerification()
                
                // data to upload to firebase
                let userData = ["email":self.user.email,
                                "username":self.user.username,
                                "admin": self.user.admin,
                                "firstName": self.user.firstName,
                "lastName": self.user.lastName] as [String:Any]
                
                self.userRef.child(userID).setValue(userData)
                self.usernameRef.childByAutoId().setValue(self.user.username)
                
            }
        }
    }
    
    
    
}
