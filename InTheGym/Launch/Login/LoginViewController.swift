//
//  LoginViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//login page. existing users can log in

import UIKit
import SCLAlertView
import Combine

class LoginViewController: UIViewController, Storyboarded {
    
    // MARK: - Properties
    weak var coordinator: SignUpCoordinator?
    
    var childContentView: LoginViewSwifUI!
    var viewModel = LoginViewModel()
    let haptic = UINotificationFeedbackGenerator()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        navigationItem.title = "Login"
        haptic.prepare()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.userSuccessfullyLoggedIn
            .sink { [weak self] in self?.receivedLoggedInUser($0) }
            .store(in: &subscriptions)
        
        viewModel.errorWhenLogginIn
            .sink { [weak self] in self?.showError(for: $0) }
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
        
        viewModel.forgotPassword
            .sink { [weak self] _ in self?.forgotPasswordButtonTapped() }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    @objc func loginButtonTapped() {
        Task {
            await viewModel.login()
        }
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
