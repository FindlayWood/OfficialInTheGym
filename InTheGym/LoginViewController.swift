//
//  LoginViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//login page. existing users can log in

import UIKit
import Firebase
import SCLAlertView

class LoginViewController: UIViewController {
    
    //variable outlets created for textfields and buttons
    @IBOutlet weak var email:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var forgotButton:UIButton!
    
    //database reference variable
    var DBref:DatabaseReference!
    
    let haptic = UINotificationFeedbackGenerator()
    
    //function to login user checking for valid info
    @IBAction func logIn(_ sender: UIButton){
        sender.pulsate()
        
        // checking verification
            
            
            
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if error == nil{
                let userID = Auth.auth().currentUser?.uid

// MARK: comment out for easy access from here
                
                if let user = Auth.auth().currentUser{
                    user.reload { (error) in
                        switch user.isEmailVerified{
                        case true:
                            self.haptic.notificationOccurred(.success)
                            UserIDToUser.transform(userID: userID!) { (user) in
                                ViewController.username = user.username
                                if user.admin! {
                                    ViewController.admin = true
                                    self.performSegue(withIdentifier: "logInAdmin2", sender: self)
                                } else {
                                    ViewController.admin = false
                                    self.performSegue(withIdentifier: "logInHome2", sender: self)
                                }
                            }
                            
                        case false:
                            // new alert
                            let alert = SCLAlertView()
                            alert.addButton("Resend verification email?") {
                                user.sendEmailVerification()
                                self.showSuccess()
                            }
                            alert.showError("Verify!", subTitle: "You have not verified your account. Please do so to login.", closeButtonTitle: "Cancel")

                        }
                    }
                }

// to here
                
// MARK: uncomment for easy access from here
                
//                self.DBref.child("users").child(userID!).child("admin").observeSingleEvent(of: .value, with: { (snapshot) in
//                    if snapshot.value as! Int == 1{
//                        self.performSegue(withIdentifier: "logInAdmin2", sender: self)
//                        ViewController.admin = true
//                    }
//                    else{
//                        self.performSegue(withIdentifier: "logInHome2", sender: self)
//                        ViewController.admin = false
//                    }
//                })
                
// to here
                
            }
            else{
                // new alert with scl
                let newalert = SCLAlertView()
                newalert.showError("Error", subTitle: "Invalid login information. Please enter valid login information.", closeButtonTitle: "Ok")
                
                //show alert when invalid info is entered
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        email.delegate = self
        password.delegate = self
        email.tintColor = .white
        password.tintColor = .white
        email.textContentType = .username
        password.textContentType = .password
        navigationItem.title = "Login"
        
        DBref = Database.database().reference()
        
        //set attributes for the text button
        let attrs : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont(name: "Menlo", size: 15)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        
        let attributeString = NSMutableAttributedString(string: "FORGOT PASSWORD?",
                                                        attributes: attrs)
        forgotButton.setAttributedTitle(attributeString, for: .normal)
        
        haptic.prepare()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        //make sure navigation bar is shown
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func showSuccess(){
        let user = Auth.auth().currentUser
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user?.email ?? "NA")")
    }

}
