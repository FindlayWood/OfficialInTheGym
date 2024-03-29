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
        view.configure(isSecure: false, textFieldPlaceHolder: "Email", errorPrompt: "Invalid Email")
        view.changeState(to: .notEnoughInfo)
        view.textFieldView.textContentType = .emailAddress
        view.textFieldView.keyboardType = .emailAddress
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var usernameField: SignUpTextFieldView = {
        let view = SignUpTextFieldView()
        view.configure(isSecure: false, textFieldPlaceHolder: "Username", errorPrompt: "This username is already taken.")
        view.changeState(to: .inValidInfo)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var passwordField: SignUpTextFieldView = {
        let view = SignUpTextFieldView()
        view.configure(isSecure: true, textFieldPlaceHolder: "Password", errorPrompt: "Passwords must be at least 6 characters long.")
        view.changeState(to: .valid)
        view.textFieldView.textContentType = .password
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
    var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "2 of 2"
        label.textColor = .darkColour
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var logoLabel: UILabel = {
        let label = UILabel()
        label.text = "INTHEGYM"
        label.font = UIFont(name: "Menlo-BoldItalic", size: 15)
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pageNumberLabel, logoLabel])
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
        backgroundColor = .systemBackground
        addSubview(stack)
        addSubview(bottomStack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            bottomStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomStack.centerXAnchor.constraint(equalTo: centerXAnchor)
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
