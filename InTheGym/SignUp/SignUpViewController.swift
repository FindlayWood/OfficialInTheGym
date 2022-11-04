//
//  SignUpViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//sign up page to create a new user

import UIKit
//import SCLAlertView
import Combine

class SignUpViewController: UIViewController, Storyboarded {
    // MARK: - Properties
    weak var coordinator: SignUpCoordinator?
    var display = SignUpView()
    var subscriptions = Set<AnyCancellable>()
    let haptic = UINotificationFeedbackGenerator()
    let viewModel = SignUpViewModel()
    
    // is the user a coach, admin = true, or player, admin = false
    var admin: Bool = false
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        haptic.prepare()
        initTargets()
        initDisplay()
        initViewModel()
//        display.signButtonValid(false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if admin {
            navigationItem.title = "COACH ACCOUNT"
            viewModel.updateAdmin(with: true)
        } else {
            navigationItem.title = "PLAYER ACCOUNT"
            viewModel.updateAdmin(with: false)
        }
    }
    // MARK: - Targets
    func initTargets() {
        display.signUpButton.addTarget(self, action: #selector(signUpPressedAction), for: .touchUpInside)
    }
    // MARK: - Display
    func initDisplay() {
        display.firstNameField.textfield.delegate = self
        display.lastNameField.textfield.delegate = self
        display.emailField.textFieldView.delegate = self
        display.usernameField.textFieldView.delegate = self
        display.passwordField.textFieldView.delegate = self
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$emailValid
            .sink { [weak self] in self?.display.emailField.changeState(to: $0)}
            .store(in: &subscriptions)
        viewModel.$usernameValid
            .sink { [weak self] in self?.display.usernameField.changeState(to: $0)}
            .store(in: &subscriptions)
        viewModel.$passwordValid
            .sink { [weak self] in self?.display.passwordField.changeState(to: $0)}
            .store(in: &subscriptions)
        viewModel.$canSignUp
            .sink { [weak self] in self?.display.signButtonValid($0)}
            .store(in: &subscriptions)
        viewModel.successfullyCreatedAccount
            .sink { [weak self] in self?.showSuccess(with: $0)}
            .store(in: &subscriptions)
        viewModel.errorCreatingAccount
            .sink { [weak self] in self?.showError(for: $0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
extension SignUpViewController {
    @objc func signUpPressedAction(_ sender: UIButton) {
        viewModel.signUpButtonPressed()
    }
}
// MARK: - Textfield Delegate
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
        return true
    }
}
// MARK: - Alerts
extension SignUpViewController {
    func showSuccess(with email: String) {
        self.haptic.notificationOccurred(.success)
//        let screenSize: CGRect = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        
//        let appearance = SCLAlertView.SCLAppearance(
//            kWindowWidth: screenWidth - 40 )
//        let newAlert = SCLAlertView(appearance: appearance)
//        newAlert.showSuccess("Account Created!", subTitle: "You have successfully created an account. We have sent a verification email to \(email), follow the steps in the email to verify your account then you will be able to login. Once you have successfully logged in your device will be remembered and you will be automatically logged in.", closeButtonTitle: "Ok")
        display.resetView()
        viewModel.resetFields()
    }
    
    func showError(for error: SignUpError) {
//        self.haptic.notificationOccurred(.success)
//        let screenSize: CGRect = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//
//        let appearance = SCLAlertView.SCLAppearance(
//            kWindowWidth: screenWidth - 40 )
//        let newAlert = SCLAlertView(appearance: appearance)
//        var errorMessage: String!
//        switch error {
//        case .invalidEmail:
//            errorMessage = "Invalid email. Please make sure to enter a valid email."
//        case .emailTaken:
//            errorMessage = "An account with this email already exists. If you have forgotten your password go to the login screen and select forgot password."
//        case .takenUsername:
//            errorMessage = "An account with this username already exists. Please choose a different one."
//        case .passwordTooShort:
//            errorMessage = "This password is too short. To keep accounts secure your password must be at least six characters long."
//        case .unknown, .fillAllFields, .passwordsDoNotMatch:
//            errorMessage = "There was an error trying to sign you up. Please try again."
//        }
//        newAlert.showError("Error", subTitle: errorMessage, closeButtonTitle: "Ok")
    }
}
