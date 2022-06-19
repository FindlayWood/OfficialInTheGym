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
import Combine

class LoginViewController: UIViewController, Storyboarded {
    
    // MARK: - Properties
    weak var coordinator: SignUpCoordinator?
//    weak var coordinator: MainCoordinator?
    var viewModel = LoginViewModel()
    var display = LoginView()
    let haptic = UINotificationFeedbackGenerator()
    var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.title = "Login"
        haptic.prepare()
        display.loginButtonValid(false)
        display.emailField.delegate = self
        display.passwordField.delegate = self
        initTargets()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.userSuccessfullyLoggedIn
            .sink { [weak self] in self?.receivedLoggedInUser($0)
//                guard let self = self else {return}
//                self.haptic.notificationOccurred(.success)
////                self.coordinator?.coordinateToTabBar()
//                self.navigationController?.popToRootViewController(animated: false)
            }.store(in: &subscriptions)
        
        viewModel.errorWhenLogginIn
            .sink { [weak self] in self?.showError(for: $0) }
            .store(in: &subscriptions)

        viewModel.$canLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.display.loginButtonValid($0) }
            .store(in: &subscriptions)
        
        viewModel.resendEmailVerificationReturned
            .sink { [weak self] sent in
                guard let self = self else {return}
                if sent {
                    self.displayTopMessage(with: "Sent email verification.")
                } else {
                    self.displayTopMessage(with: "Error. Try Again.")
                }
            }.store(in: &subscriptions)
    }
    
    // MARK: - Targets
    func initTargets() {
        display.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        display.forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func loginButtonTapped() {
        viewModel.login()
    }
    @objc func forgotPasswordButtonTapped() {
        coordinator?.forgotPassword()
    }
    func receivedLoggedInUser(_ user: Users) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if user.admin {
            appDelegate.loggedInCoach()
        } else {
            appDelegate.loggedInPlayer()
        }
    }
    // MARK: - Alerts
    func showError(for error: loginError) {
        switch error {
        case .emailNotVerified(let user):
            let alert = SCLAlertView()
            alert.addButton("Resend verification email?") { [weak self] in
                self?.viewModel.resendEmailVerification(to: user)
            }
            alert.showError("Verify!", subTitle: "You have not verified your account. Please do so to login.", closeButtonTitle: "Cancel")
        case .invalidCredentials, .unKnown:
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "There was an error logging you in, make sure you enter the correct email and password. If you forgot your password tap FORGOT PASSWORD.", closeButtonTitle: "Ok")
        }
    }
}

// MARK: - Textfield Delegate
extension LoginViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == display.emailField {
            viewModel.updateEmail(with: newString)
        }
        if textField == display.passwordField {
            viewModel.updatePassword(with: newString)
        }
        return true
    }
}
