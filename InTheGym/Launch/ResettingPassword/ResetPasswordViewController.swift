//
//  ResetPasswordViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/08/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//
// resetting email page

import UIKit
import Firebase
//import SCLAlertView
import Combine

class ResetPasswordViewController: UIViewController {
    // MARK: - Properties
    var display = ResettingPasswordView()
    var viewModel = ResettingPasswordViewModel()
    var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initViewModel()
        initTargets()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Display
    func initDisplay() {
        display.emailField.delegate = self
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isEmailValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emailValid in
                self?.display.sendButton.isEnabled = emailValid
                self?.display.sendButtonValid(emailValid)
            }.store(in: &subscriptions)
        
        viewModel.emailSentSuccessfully
            .sink { [weak self] successful in
                guard let self = self else {return}
                self.display.setLoading(to: false)
                self.showAlert(for: successful)
            }.store(in: &subscriptions)
    }
}
// MARK: - Targets
private extension ResetPasswordViewController {
    func initTargets() {
        display.sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
    }
}
// MARK: - Actions
private extension ResetPasswordViewController {
    @objc func sendButtonTapped(_ sender: UIButton) {
        viewModel.sendButtonAction()
        display.setLoading(to: true)
    }
}
// MARK: - Alerts
private extension ResetPasswordViewController {
    func showAlert(for success: Bool) {
//        if success {
//            let alert = SCLAlertView()
//            alert.showSuccess("Sent!", subTitle: "Reset email sent. Follow instructions in the email to change your password.", closeButtonTitle: "ok")
//            display.emailField.text = ""
//            viewModel.updateEmail(with: "")
//        } else {
//            let alert = SCLAlertView()
//            alert.showError("Error", subTitle: "Failed to send reset email, please try again.", closeButtonTitle: "ok")
//        }
    }
}
// MARK: - Textfield delegate
extension ResetPasswordViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == display.emailField {
            viewModel.updateEmail(with: newString)
        }
        return true
    }
}
