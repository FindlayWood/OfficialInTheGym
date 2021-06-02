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

class LaunchPageViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    @IBOutlet var spinner:UIActivityIndicatorView!
    
    var DBref: DatabaseReference!

    fileprivate func checkForUser() {
        
        FirebaseAuthManager.shared.checkForCurrentUser { result in
            self.spinner.stopAnimating()
            switch result {
            case .success(let user):
                let uid = user.uid
                UserIDToUser.transform(userID: uid) { userObject in
                    ViewController.admin = userObject.admin
                    ViewController.username = userObject.username
                    self.coordinator?.coordinateToTabBar()
                }
            case .failure(let error):
                switch error{
                case .noUser:
                    print("no user")
                case .reloadError:
                    self.showError(with: "There was an error logging you in, please try again.")
                case .notVerified(let notVerifiedUser):
                    self.showNotVerified(to: notVerifiedUser)
                }
                self.coordinator?.notLoggedIn()
            }
        }
        
        
//        if Auth.auth().currentUser != nil{
//            let userID = Auth.auth().currentUser?.uid
//            if let user = Auth.auth().currentUser{
//
//                user.reload { (error) in
//                    switch user.isEmailVerified {
//                    case true:
//                        //self.perform(#selector(self.showAlert), with: nil, afterDelay: 10)
//                        UserIDToUser.transform(userID: userID!) { (user) in
//                            ViewController.username = user.username
//                            if user.admin! {
//                                ViewController.admin = true
//                                self.spinner.stopAnimating()
//                                //self.performSegue(withIdentifier: "coachLoggedIn", sender: self)
//                                self.coordinator?.coordinateToTabBar()
//                            } else {
//                                ViewController.admin = false
//                                self.spinner.stopAnimating()
//                                //self.performSegue(withIdentifier: "playerLoggedIn", sender: self)
//                                self.coordinator?.coordinateToTabBar()
//                            }
//                        }
//
//                    case false:
//                        self.spinner.stopAnimating()
//                        //self.performSegue(withIdentifier: "toLoginSignUp", sender: self)
//                        self.coordinator?.notLoggedIn()
//                    }
//                }
//
//            }
//
//        }else{
//            self.spinner.stopAnimating()
//            //self.performSegue(withIdentifier: "toLoginSignUp", sender: self)
//            self.coordinator?.notLoggedIn()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        DBref = Database.database().reference()
        
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        //checkForUser()
    }
    
    func showSuccess(){
        let user = Auth.auth().currentUser
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user?.email ?? "NA")")
    }
    func showError(with message: String) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: message, closeButtonTitle: "ok")
    }
    func showNotVerified(to user: User) {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40 )
        
        let alertview = SCLAlertView(appearance: appearance)
        alertview.addButton("Resend Verification Email") {
            user.sendEmailVerification()
            self.showSuccess()
        }
        
        alertview.showWarning("Verify", subTitle: "You must verify your account from the email we sent you. Then we can log you in straight away.", closeButtonTitle: "OK")
    }
    
    // set navigation bar hidden
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        checkForUser()
    }
    

}
