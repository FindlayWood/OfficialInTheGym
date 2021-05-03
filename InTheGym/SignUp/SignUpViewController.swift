//
//  SignUpViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//sign up page to create a new user

import UIKit
import SCLAlertView

class SignUpViewController: UIViewController {
    
    // outlet variables to for the signup fields
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm :UITextField!
    
    let haptic = UINotificationFeedbackGenerator()
    
    let viewModel = SignUpViewModel()
    
    // is the user a coach, admin = true, or player, admin = false
    var admin: Bool = false
    
    
    // function for when the user taps signup. checks all fields for valid info
    @IBAction func signUp(_ sender: UIButton){
        viewModel.loginAttempt()
        sender.pulsate()
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
        email.tintColor = .white
        username.tintColor = .white
        firstName.tintColor = .white
        lastName.tintColor = .white
        password.tintColor = .white
        passwordConfirm.tintColor = .white
        
        
        if admin{
            navigationItem.title = "COACH ACCOUNT"
            viewModel.updateAdmin(with: true)
        }else{
            navigationItem.title = "PLAYER ACCOUNT"
            viewModel.updateAdmin(with: false)
        }
        initViewModel()
           
    }
    
    func initViewModel(){
        
        viewModel.SignUpFailedClosure = { (error) in
            var errorMessage:String!
            switch error {
            case .emailTaken:
                errorMessage = "This is email is already in use."
                self.email.text = ""
            case .fillAllFields:
                errorMessage = "Please fill in all the fields."
            case .invalidEmail:
                errorMessage = "Please use a valid email."
                self.email.text = ""
            case .passwordTooShort:
                errorMessage = "That password is too short. Passwords must be at least six characters."
            case .passwordsDoNotMatch:
                errorMessage = "Passwords do not match."
                self.password.text = ""
                self.passwordConfirm.text = ""
            case .takenUsername:
                errorMessage = "This username is already in use. Please choose another."
                self.username.text = ""
            case .unknown:
                errorMessage = "There was an error."
            }
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: errorMessage, closeButtonTitle: "ok")
        }
        
        viewModel.SignUpSuccesfulClosure = { [weak self] (email) in
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )
            let newAlert = SCLAlertView(appearance: appearance)
            newAlert.showSuccess("Account Created!", subTitle: "You have successfully created an account. We have sent a verification email to \(email), follow the steps in the email to verify your account then you will be able to login. Once you have successfully logged in your device will be remembered and you will be automatically logged in.", closeButtonTitle: "Ok")
            self?.email.text = ""
            self?.firstName.text = ""
            self?.lastName.text = ""
            self?.username.text = ""
            self?.password.text = ""
            self?.passwordConfirm.text = ""
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
        
    }

}
extension SignUpViewController  {
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        let text = textField.text!
//        if textField == email {
//            viewModel.updateEmail(with: text)
//        }
//        if textField == username {
//            viewModel.updateUsername(with: text)
//        }
//        if textField == firstName {
//            viewModel.updateFirstName(with: text)
//        }
//        if textField == lastName {
//            viewModel.updateLastName(with: text)
//        }
//        if textField == password {
//            viewModel.updatePassword(with: text)
//        }
//        if textField == passwordConfirm {
//            viewModel.updateConfirmPassword(with: text)
//        }
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == email {
            viewModel.updateEmail(with: newString)
        }
        if textField == username {
            viewModel.updateUsername(with: newString)
        }
        if textField == firstName {
            viewModel.updateFirstName(with: newString)
        }
        if textField == lastName {
            viewModel.updateLastName(with: newString)
        }
        if textField == password {
            viewModel.updatePassword(with: newString)
        }
        if textField == passwordConfirm {
            viewModel.updateConfirmPassword(with: newString)
        }
        return true
    }
    
}
