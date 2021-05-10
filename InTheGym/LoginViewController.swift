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

class LoginViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
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
        
        FirebaseAuthManager.shared.loginUser(with: email.text!, and: password.text!) { result in
            switch result {
            case .success(let user):
                user.reload { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else {
                        switch user.isEmailVerified {
                        case true:
                            UserIDToUser.transform(userID: user.uid) { userModel in
                                ViewController.username = userModel.username
                                ViewController.admin = userModel.admin
                                self.coordinator?.coordinateToTabBar()
                                self.navigationController?.popToRootViewController(animated: false)
                            }
                        case false:
                            let alert = SCLAlertView()
                            alert.addButton("Resend verification email?") {
                                user.sendEmailVerification()
                                self.showSuccess()
                            }
                            alert.showError("Verify!", subTitle: "You have not verified your account. Please do so to login.", closeButtonTitle: "Cancel")
                            
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                let newalert = SCLAlertView()
                newalert.showError("Error", subTitle: "Invalid login information. Please enter valid login information.", closeButtonTitle: "Ok")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        email.delegate = self
        password.delegate = self
        email.tintColor = Constants.darkColour
        password.tintColor = Constants.darkColour
        email.textContentType = .username
        password.textContentType = .password
        navigationItem.title = "Login"
        email.becomeFirstResponder()
        
        DBref = Database.database().reference()
        
        //set attributes for the text button
        let attrs : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont(name: "Menlo", size: 15)!,
            NSAttributedString.Key.foregroundColor : UIColor.black,
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
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
    }
    
    func showSuccess(){
        let user = Auth.auth().currentUser
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user?.email ?? "NA")")
    }

}
