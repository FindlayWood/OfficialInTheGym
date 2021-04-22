//
//  LaunchPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
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
                        UserIDToUser.transform(userID: userID!) { (user) in
                            ViewController.username = user.username
                            if user.admin! {
                                ViewController.admin = true
                                self.spinner.stopAnimating()
                                self.performSegue(withIdentifier: "coachLoggedIn", sender: self)
                            } else {
                                ViewController.admin = false
                                self.spinner.stopAnimating()
                                self.performSegue(withIdentifier: "playerLoggedIn", sender: self)
                            }
                        }
                        
                    case false:
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: "toLoginSignUp", sender: self)
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
