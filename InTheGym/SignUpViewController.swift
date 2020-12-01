//
//  SignUpViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//sign up page to create a new user

import UIKit
import Firebase
import Flurry_iOS_SDK
import SCLAlertView

class SignUpViewController: UIViewController {
    
    // outlet variables to for the signup fields
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm :UITextField!
    
    @IBOutlet var accountLabel:UILabel!
    
    let haptic = UINotificationFeedbackGenerator()

    
    
    // database reference
    var userRef: DatabaseReference!
    // database reference for first activity
    var ActRef: DatabaseReference!
    // is the user a coach, admin = true, or player, admin = false
    var admin: Bool = false
    var usernames = [String]()
    
    
    
    // function for when the user taps signup. checks all fields for valid info
    @IBAction func signUp(_ sender: UIButton){
        Flurry.logEvent("SignUp Page-SignUp button")
        sender.pulsate()
        // check no field is emoty
        if firstName.text!.isEmpty || lastName.text!.isEmpty || email.text!.isEmpty || username.text!.isEmpty{
            let alert = SCLAlertView()
            alert.showError("Error!", subTitle: "Make sure all information has been entered.")
            Flurry.logEvent("SignUp Page-Empty Info")
        }
        else{
            // check that username is unique
            if usernames.contains(username.text!) || Constants.bannedUsernames.contains(username.text!){
                let alert = SCLAlertView()
                alert.showError("Error!", subTitle: "Username already exists. Please choose another username.")
                username.text = ""
                Flurry.logEvent("SignUp Page-Username exists")
            }
            else{
                // check if passwords match
                if password.text != passwordConfirm.text{
                    let alert = SCLAlertView()
                    alert.showError("Error!", subTitle: "Passwords do not match.")
                    password.text = ""
                    passwordConfirm.text = ""
                    Flurry.logEvent("SignUp Page-Passwords dont match")
                }
                else{
                    // create new user
                    Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                        if error == nil{
                            self.haptic.prepare()
                            Flurry.logEvent("SignUp Page-Clean SignUp")
                            
                            //let key = self.userRef.childByAutoId().key
                            let userID = Auth.auth().currentUser!.uid
                            let user = Auth.auth().currentUser!
                            
                            user.sendEmailVerification()
                            
                            let userData = ["email":self.email.text!,
                                            "username":self.username.text!,
                                            "admin":self.admin,
                                            "firstName":self.firstName.text!,
                                            "lastName":self.lastName.text!] as [String : Any]
                            
                            self.userRef.child(userID).setValue(userData)
                            
                            let actData = ["time":ServerValue.timestamp(),
                                           "message":"\(self.username.text!), welcome to InTheGym!",
                                           "type":"Account Created"] as [String:AnyObject]
                            
                            
                            self.ActRef.child(userID).childByAutoId().setValue(actData)
                            //self.userRef.child(userID).child("activities").childByAutoId().setValue(actData)
                            
                            self.haptic.notificationOccurred(.success)
                            
                            let newAlert = SCLAlertView()
                            newAlert.showSuccess("Account Created!", subTitle: "You have successfully created an account. We have sent a verification email to \(user.email ?? "NA"), follow the steps in the email to verify your account then you will be able to login. Once you have successfully logged in your device will be remembered and you will be automatically logged in.", closeButtonTitle: "Ok")
                            
                            
                            // send user to the correct page. either coach or player
                            // stop sending, make them verify email
                            // write alert so they know to use a valid email address
                            // here is the comment out section for easy access
                            /*if self.admin == true{
                                self.performSegue(withIdentifier: "adminPage2", sender: self)
                                ViewController.admin = true
                            }
                            else{
                                self.performSegue(withIdentifier: "signUpHome2", sender: self)
                                ViewController.admin = false
                            }*/
                        }
                        else if self.password.text!.count < 6{
                            //check length of password
                            
                            // new alert
                            let alert = SCLAlertView()
                            alert.showError("Error!", subTitle: "Password too short. Your password must be at least 6 characters.")
                            
                            self.password.text = ""
                            self.passwordConfirm.text = ""
                            Flurry.logEvent("SignUp Page-Password too short")
                        }
                            
                        else{
                            // check that email is unique
                            
                            // new alert
                            let alert = SCLAlertView()
                            alert.showError("Error!", subTitle: "An account with this email address already exists. If you have previously created an account you can login with this email address.")
                            self.email.text = ""
                            Flurry.logEvent("SignUp Page-Email already exists exists")
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        email.delegate = self
        username.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        password.delegate = self
        passwordConfirm.delegate = self
        
        if admin{
            accountLabel.text = "COACH ACCOUNT"
        }else{
            accountLabel.text = "PLAYER ACCOUNT"
        }
        
        userRef = Database.database().reference().child("users")
        ActRef = Database.database().reference().child("Activities")
        checkUsernames()
        
//        let warningalert = SCLAlertView()
//        warningalert.showNotice("Verification", subTitle: "New accounts must be verified and you will be sent an email to verify your account before you can login.", closeButtonTitle: "Ok")
        
        
    }
    
    
    // fucntion to load over all usernames. used later to check for unique password
    func checkUsernames(){
        self.userRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let user = Users()
                user.username = dictionary["username"] as? String
                self.usernames.append(user.username!)
            }
        }, withCancel: nil)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }

}
