//
//  LoginView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginView: UIView {
    
    // MARK: - Subviews
    var emailField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.font = .systemFont(ofSize: 20, weight: .medium)
        field.tintColor = .darkColour
        field.returnKeyType = .done
        field.textColor = .darkColour
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 1
        field.titleColor = .black
        field.lineColor = .lightGray
        field.title = "Email"
        field.selectedTitle = "Email"
        field.selectedTitleColor = .darkColour
        field.selectedLineColor = .darkColour
        field.placeholder = "email"
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.textContentType = .username
        field.keyboardType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var passwordField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.font = .systemFont(ofSize: 20, weight: .medium)
        field.tintColor = .darkColour
        field.returnKeyType = .done
        field.textColor = .darkColour
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 1
        field.titleColor = .black
        field.lineColor = .lightGray
        field.title = "Password"
        field.selectedTitle = "Password"
        field.selectedTitleColor = .darkColour
        field.selectedLineColor = .darkColour
        field.placeholder = "password"
        field.textContentType = .password
        field.isSecureTextEntry = true
        field.clearButtonMode = .never
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("FORGOT PASSWORD", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.backgroundColor = .clear
        view.style = .large
        view.color = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
// MARK: - Setup UI
private extension LoginView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(emailField)
        addSubview(passwordField)
        addSubview(loginButton)
        addSubview(forgotPasswordButton)
        addSubview(loadingIndicator)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension LoginView {
    public func loginButtonValid(_ valid: Bool) {
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        loginButton.layer.shadowRadius = valid ? 6.0 : 0
        loginButton.layer.shadowOpacity = valid ? 1.0 : 0
        loginButton.backgroundColor = .darkColour.withAlphaComponent(valid ? 1.0 : 0.7)
        loginButton.isEnabled = valid
    }
    
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
