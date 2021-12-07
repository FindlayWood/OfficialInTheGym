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
import SCLAlertView
import Combine

class ResetPasswordViewController: UIViewController {
    
    var display = ResettingPasswordView()
    
    var viewModel = ResettingPasswordViewModel()
    
    var subscriptions = Set<AnyCancellable>()
    
//    @IBOutlet weak var emailTextField:UITextField!
//    
//    @IBAction func resetPressed(_ sender:UIButton){
//        if emailTextField.text!.isEmpty{
//            
//            // new alert from update 1.1 - not added
//            let alert = SCLAlertView()
//            alert.showWarning("Error", subTitle: "Enter email.", closeButtonTitle: "ok")
//            
//        }
//        else{
//            let email = emailTextField.text!
//            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
//                if let error = error{
//                    print(error)
//                    
//                    // new alert from update 1.1
//                    let alert = SCLAlertView()
//                    alert.showError("Error", subTitle: "Failed to send reset email, please try again.", closeButtonTitle: "ok")
//                    
//                    
//                }
//                else{
//                    // new alert from update 1.1
//                    let alert = SCLAlertView()
//                    alert.showSuccess("Sent!", subTitle: "Reset email sent. Follow instructions in the email to change your password.", closeButtonTitle: "ok")
//                    
//                    
//                    self.emailTextField.text = ""
//                }
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Reset Password"
        view.backgroundColor = .white
        
        display.emailField.delegate = self
        
        setupButtonActions()

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
    
    func setupButtonActions() {
        display.sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func sendButtonTapped(_ sender: UIButton) {
        viewModel.sendButtonAction()
        display.setLoading(to: true)
    }

    func showAlert(for success: Bool) {
        if success {
            let alert = SCLAlertView()
            alert.showSuccess("Sent!", subTitle: "Reset email sent. Follow instructions in the email to change your password.", closeButtonTitle: "ok")
            display.emailField.text = ""
            viewModel.updateEmail(with: "")
        } else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Failed to send reset email, please try again.", closeButtonTitle: "ok")
        }
    }
}

extension ResetPasswordViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == display.emailField {
            viewModel.updateEmail(with: newString)
        }
        return true
    }
}
