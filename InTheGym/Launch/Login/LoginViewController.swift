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
    
    weak var coordinator: MainCoordinator?
    
    var viewModel = LoginViewModel()
    
    var display = LoginView()
    
    let haptic = UINotificationFeedbackGenerator()
    
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.title = "Login"
        
        haptic.prepare()
        
        display.loginButtonValid(false)
        display.emailField.delegate = self
        display.passwordField.delegate = self
        
        buttonActions()
        
        viewModel.userSuccessfullyLoggedIn
            .sink { [weak self] loggedInUser in
                guard let self = self else {return}
                self.display.setLoading(to: false)
                self.haptic.notificationOccurred(.success)
                self.coordinator?.coordinateToTabBar()
                self.navigationController?.popToRootViewController(animated: false)
            }.store(in: &subscriptions)
        
        viewModel.errorWhenLogginIn
            .sink { [weak self] error in
                guard let self = self else {return}
                self.showError(for: error)
                self.display.setLoading(to: false)
            }.store(in: &subscriptions)

        viewModel.$canLogin
            .receive(on: DispatchQueue.main)
            .map { return $0 }
            .sink { [weak self] loginValid in
                self?.display.loginButton.isEnabled = loginValid
                self?.display.loginButtonValid(loginValid)
            }.store(in: &subscriptions)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    
    func buttonActions() {
        display.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        display.forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
    }
    
    @objc func loginButtonTapped() {
        viewModel.loginButtonAction()
        display.setLoading(to: true)
    }
    @objc func forgotPasswordButtonTapped() {
        coordinator?.forgotPassword()
    }

    
    func showError(for error: loginError) {
        switch error {
        case .emailNotVerified(let user):
            let alert = SCLAlertView()
            alert.addButton("Resend verification email?") {
                self.viewModel.resendEmailVerification(to: user)
            }
            alert.showError("Verify!", subTitle: "You have not verified your account. Please do so to login.", closeButtonTitle: "Cancel")
        case .invalidCredentials, .unKnown:
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "There was an error logging you in, make sure you enter the correct email and password. If you forgot your password tap FORGOT PASSWORD.", closeButtonTitle: "Ok")
        }
    }
}

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
