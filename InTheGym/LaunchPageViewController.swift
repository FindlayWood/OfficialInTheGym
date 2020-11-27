//
//  LaunchPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import Flurry_iOS_SDK
import SCLAlertView

class LaunchPageViewController: UIViewController {
    
    @IBOutlet var spinner:UIActivityIndicatorView!
    
    var DBref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        DBref = Database.database().reference()
        
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        if Auth.auth().currentUser != nil{
            let userID = Auth.auth().currentUser?.uid
            if let user = Auth.auth().currentUser{
                
                user.reload { (error) in
                    switch user.isEmailVerified {
                    case true:
                        //self.perform(#selector(self.showAlert), with: nil, afterDelay: 10)
                        self.DBref.child("users").child(userID!).child("admin").observeSingleEvent(of: .value) { (snapshot) in
                            
                            if snapshot.value as! Int == 1{
                                self.spinner.stopAnimating()
                                self.performSegue(withIdentifier: "coachLoggedIn", sender: self)
                                ViewController.admin = true
                                Flurry.logEvent("Coach Already logged in")
                            }
                            else{
                                self.spinner.stopAnimating()
                                self.performSegue(withIdentifier: "playerLoggedIn", sender: self)
                                ViewController.admin = false
                                Flurry.logEvent("Player already logged in")
                            }
                        }
                    case false:
                        self.spinner.stopAnimating()
                        let screenSize: CGRect = UIScreen.main.bounds
                        let screenWidth = screenSize.width
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            kWindowWidth: screenWidth - 40 )
                        
                        let alertview = SCLAlertView(appearance: appearance)
                        alertview.addButton("Resend Verification Email") {
                            user.sendEmailVerification()
                            self.showSuccess()
                            self.performSegue(withIdentifier: "toLoginSignUp", sender: self)
                        }
                        
                        alertview.showWarning("Verify", subTitle: "You must verify your account from the email we sent you. Then we can log you in straight away.", closeButtonTitle: "OK")
                        
                        
                    }
                }
               
            }
            
        }else{
            self.spinner.stopAnimating()
            self.performSegue(withIdentifier: "toLoginSignUp", sender: self)
        }
    }
    
    func showSuccess(){
        let user = Auth.auth().currentUser
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user?.email ?? "NA")")
    }
    
    // set navigation bar hidden
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

}
