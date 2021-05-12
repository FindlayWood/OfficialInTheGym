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

class SignUpViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
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
        haptic.prepare()
        
        email.delegate = self
        username.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        password.delegate = self
        passwordConfirm.delegate = self
        email.tintColor = Constants.darkColour
        username.tintColor = Constants.darkColour
        firstName.tintColor = Constants.darkColour
        lastName.tintColor = Constants.darkColour
        password.tintColor = Constants.darkColour
        passwordConfirm.tintColor = Constants.darkColour
        
        
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
        
        viewModel.SignUpFailedClosure = { [weak self] (error) in
            guard let self = self else {return}
            var errorMessage: String!
            switch error {
            case .emailTaken:
                errorMessage = SignUpError.emailTaken.rawValue
                self.email.text = ""
            case .fillAllFields:
                errorMessage = SignUpError.fillAllFields.rawValue
            case .invalidEmail:
                errorMessage = SignUpError.invalidEmail.rawValue
                self.email.text = ""
            case .passwordTooShort:
                errorMessage = SignUpError.passwordTooShort.rawValue
            case .passwordsDoNotMatch:
                errorMessage = SignUpError.passwordsDoNotMatch.rawValue
                self.password.text = ""
                self.passwordConfirm.text = ""
            case .takenUsername:
                errorMessage = SignUpError.takenUsername.rawValue
                self.username.text = ""
            case .unknown:
                errorMessage = SignUpError.unknown.rawValue
            }
            self.haptic.notificationOccurred(.warning)
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: errorMessage, closeButtonTitle: "ok")
        }
        
        viewModel.SignUpSuccesfulClosure = { [weak self] (email) in
            guard let self = self else {return}
            self.haptic.notificationOccurred(.success)
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )
            let newAlert = SCLAlertView(appearance: appearance)
            newAlert.showSuccess("Account Created!", subTitle: "You have successfully created an account. We have sent a verification email to \(email), follow the steps in the email to verify your account then you will be able to login. Once you have successfully logged in your device will be remembered and you will be automatically logged in.", closeButtonTitle: "Ok")
            self.email.text = ""
            self.firstName.text = ""
            self.lastName.text = ""
            self.username.text = ""
            self.password.text = ""
            self.passwordConfirm.text = ""
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
