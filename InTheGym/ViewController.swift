//
//  ViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.

//initial view controller with login and signup buttons

import UIKit
import Firebase
import Network
import Flurry_iOS_SDK
import SCLAlertView


class ViewController: UIViewController {
    
    var DBref: DatabaseReference!
    
    
    static var admin:Bool!
    
    let monitor = NWPathMonitor()
    

    override func viewDidLoad() {
        
        //check for internet connection
        monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied{
                self.showAlert()
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        DBref = Database.database().reference()
        
        super.viewDidLoad()
        // check if current user exists and log them in
        if Auth.auth().currentUser != nil{
            let userID = Auth.auth().currentUser?.uid
            if let user = Auth.auth().currentUser{
                
                user.reload { (error) in
                    switch user.isEmailVerified {
                    case true:
                        //self.perform(#selector(self.showAlert), with: nil, afterDelay: 10)
                        self.DBref.child("users").child(userID!).child("admin").observeSingleEvent(of: .value) { (snapshot) in
                            
                            if snapshot.value as! Int == 1{
                                self.performSegue(withIdentifier: "adminLoggedIn2", sender: self)
                                ViewController.admin = true
                                Flurry.logEvent("Coach Already logged in")
                            }
                            else{
                                self.performSegue(withIdentifier: "alreadyLoggedIn2", sender: self)
                                ViewController.admin = false
                                Flurry.logEvent("Player already logged in")
                            }
                        }
                    case false:
                        let screenSize: CGRect = UIScreen.main.bounds
                        let screenWidth = screenSize.width
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            kWindowWidth: screenWidth - 40 )
                        
                        let alertview = SCLAlertView(appearance: appearance)
                        alertview.addButton("Resend Verification Email") {
                            user.sendEmailVerification()
                            self.showSuccess()
                        }
                        
                        alertview.showWarning("Verify", subTitle: "You must verify your account from the email we sent you. The we can log you in straight away.", closeButtonTitle: "OK")
                        
                        
                    }
                }
               
            }
            

            
            /*self.DBref.child("users").child(userID!).child("admin").observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.value as! Int == 1{
                    self.performSegue(withIdentifier: "adminLoggedIn2", sender: self)
                    ViewController.admin = true
                    Flurry.logEvent("Coach Already logged in")
                }
                else{
                    self.performSegue(withIdentifier: "alreadyLoggedIn2", sender: self)
                    ViewController.admin = false
                    Flurry.logEvent("Player already logged in")
                }
            }*/
            
        }
    }
    
    // function when either button is tapped to navigate to the correct page
    @IBAction func tapped(_ sender:UIButton){
        sender.pulsate()
        Flurry.logEvent("Login/Signup", withParameters: ["title":sender.titleLabel?.text! ?? "NA"])
        
        
    }
    
    // set navigation bar hidden
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    // alert to show when user has no internet connection
    @objc func showAlert(){
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("Error", subTitle: "You must have an internet connection to use this app. Please connect to the internet and try again.")
        
    }
    
    func showSuccess(){
        let user = Auth.auth().currentUser
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user?.email ?? "NA")")
    }
    


}

