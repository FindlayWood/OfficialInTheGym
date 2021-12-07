//
//  SignUpView.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var firstNameField: SkyFloatingTextField = {
        let view = SkyFloatingTextField()
        view.configure(with: "First Name")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var lastNameField: SkyFloatingTextField = {
        let view = SkyFloatingTextField()
        view.configure(with: "Last Name")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var emailField: SignUpTextFieldView = {
        let view = SignUpTextFieldView()
        view.configure(isSecure: false, textFieldPlaceHolder: "Email", errorPrompt: "Invlaid Email")
        view.changeState(to: .notEnoughInfo)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var usernameField: SignUpTextFieldView = {
        let view = SignUpTextFieldView()
        view.configure(isSecure: false, textFieldPlaceHolder: "Username", errorPrompt: "InvalidUsername.")
        view.changeState(to: .inValidInfo)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var passwordField: SignUpTextFieldView = {
        let view = SignUpTextFieldView()
        view.configure(isSecure: true, textFieldPlaceHolder: "Password", errorPrompt: "Invalid password.")
        view.changeState(to: .valid)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstNameField, lastNameField, emailField, usernameField, passwordField, signUpButton])
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension SignUpView {
    func setupUI() {
        backgroundColor = .white
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}

extension SignUpView {
    public func signButtonValid(_ valid: Bool) {
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        signUpButton.layer.shadowRadius = valid ? 6.0 : 0
        signUpButton.layer.shadowOpacity = valid ? 1.0 : 0
        signUpButton.backgroundColor = .darkColour.withAlphaComponent(valid ? 1.0 : 0.7)
    }
    public func resetView() {
        firstNameField.textfield.text = ""
        lastNameField.textfield.text = ""
        emailField.textFieldView.text = ""
        usernameField.textFieldView.text = ""
        passwordField.textFieldView.text = ""
    }
}

