//
//  ResetPasswordViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/08/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//
// resetting email page

import UIKit
import SCLAlertView
import Combine

class ResetPasswordViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: SignUpCoordinator?
    var childContentView: ResetPasswordView!
    var display = ResettingPasswordView()
    var viewModel = ResettingPasswordViewModel()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
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
        if success {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false)
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Ok") {
                self.coordinator?.resetPasswordSent()
            }
            alert.showSuccess("Sent!", subTitle: "Reset email sent. Follow instructions in the email to change your password.")
            viewModel.updateEmail(with: "")
        } else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Failed to send reset email, please try again.", closeButtonTitle: "ok")
        }
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
