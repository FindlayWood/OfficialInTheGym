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
import Combine

class SignUpViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    var display = SignUpView()
    
    var subscriptions = Set<AnyCancellable>()
    
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
        //viewModel.loginAttempt()
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
        
        display.firstNameField.textfield.delegate = self
        display.lastNameField.textfield.delegate = self
        display.emailField.textFieldView.delegate = self
        display.usernameField.textFieldView.delegate = self
        display.passwordField.textFieldView.delegate = self
        
        
        if admin {
            navigationItem.title = "COACH ACCOUNT"
            viewModel.updateAdmin(with: true)
        } else {
            navigationItem.title = "PLAYER ACCOUNT"
            viewModel.updateAdmin(with: false)
        }
        initViewModel()
        display.signButtonValid(false)
        setUpSubscriptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
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
        editNavBarColour(to: .darkColour)
        navigationController?.setNavigationBarHidden(false, animated: true)
//        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.darkColour]
//        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
//        self.navigationController?.navigationBar.tintColor = Constants.darkColour
        
    }
    
    func setUpSubscriptions() {
        
        viewModel.$emailValid
            .sink { [weak self] validState in
                guard let self = self else {return}
                self.display.emailField.changeState(to: validState)
            }
            .store(in: &subscriptions)
        
        viewModel.$usernameValid
            .sink { [weak self] validState in
                guard let self = self else {return}
                self.display.usernameField.changeState(to: validState)
            }
            .store(in: &subscriptions)
        
        viewModel.$passwordValid
            .sink { [weak self] validState in
                guard let self = self else {return}
                self.display.passwordField.changeState(to: validState)
            }
            .store(in: &subscriptions)
            
        viewModel.$canSignUp
            .sink { [weak self] signUpAllowed in
                guard let self = self else {return}
                self.display.signButtonValid(signUpAllowed)
            }
            .store(in: &subscriptions)
        
        viewModel.successfullyCreatedAccount
            .sink { [weak self] email in
                guard let self = self else {return}
                self.showSuccess(with: email)
            }
            .store(in: &subscriptions)
        
        viewModel.errorCreatingAccount
            .sink { [weak self] error in
                guard let self = self else {return}
                self.showError(for: error)
            }
            .store(in: &subscriptions)
    }

}
extension SignUpViewController  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == display.emailField.textFieldView {
            viewModel.updateEmail(with: newString)
        }
        if textField == display.usernameField.textFieldView {
            viewModel.updateUsername(with: newString)
        }
        if textField == display.firstNameField.textfield {
            viewModel.updateFirstName(with: newString)
        }
        if textField == display.lastNameField.textfield {
            viewModel.updateLastName(with: newString)
        }
        if textField == display.passwordField.textFieldView {
            viewModel.updatePassword(with: newString)
        }
//        if textField == passwordConfirm {
//            viewModel.updateConfirmPassword(with: newString)
//        }
        return true
    }
}

// MARK: - Alerts
extension SignUpViewController {
    func showSuccess(with email: String) {
        self.haptic.notificationOccurred(.success)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40 )
        let newAlert = SCLAlertView(appearance: appearance)
        newAlert.showSuccess("Account Created!", subTitle: "You have successfully created an account. We have sent a verification email to \(email), follow the steps in the email to verify your account then you will be able to login. Once you have successfully logged in your device will be remembered and you will be automatically logged in.", closeButtonTitle: "Ok")
        display.resetView()
        viewModel.resetFields()
    }
    
    func showError(for error: SignUpError) {
        self.haptic.notificationOccurred(.success)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40 )
        let newAlert = SCLAlertView(appearance: appearance)
        var errorMessage: String!
        switch error {
        case .invalidEmail:
            errorMessage = "Invalid email. Please make sure to enter a valid email."
        case .emailTaken:
            errorMessage = "An account with this email already exists. If you have forgotten your password go to the login screen and select forgot password."
        case .takenUsername:
            errorMessage = "An account with this username already exists. Please choose a different one."
        case .passwordTooShort:
            errorMessage = "This password is too short. To keep accounts secure your password must be at least six characters long."
        case .unknown, .fillAllFields, .passwordsDoNotMatch:
            errorMessage = "There was an error trying to sign you up. Please try again."
        }
        newAlert.showError("Error", subTitle: errorMessage, closeButtonTitle: "Ok")
    }
}
