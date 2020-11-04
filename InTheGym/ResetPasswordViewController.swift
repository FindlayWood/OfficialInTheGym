//
//  ResetPasswordViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/08/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//
// resetting email page

import UIKit
import Firebase
import SCLAlertView

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField:UITextField!
    
    @IBAction func resetPressed(_ sender:UIButton){
        if emailTextField.text!.isEmpty{
            
            // new alert from update 1.1 - not added
            let alert = SCLAlertView()
            alert.showWarning("Error", subTitle: "Enter email.", closeButtonTitle: "ok")
            
        }
        else{
            let email = emailTextField.text!
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error{
                    print(error)
                    
                    // new alert from update 1.1
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Failed to send reset email, please try again.", closeButtonTitle: "ok")
                    
                    
                }
                else{
                    // new alert from update 1.1
                    let alert = SCLAlertView()
                    alert.showSuccess("Sent!", subTitle: "Reset email sent. Follow instructions in the email to change your password.", closeButtonTitle: "ok")
                    
                    
                    self.emailTextField.text = ""
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    


}
