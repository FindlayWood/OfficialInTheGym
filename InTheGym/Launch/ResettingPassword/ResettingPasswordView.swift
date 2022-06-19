//
//  ResettingPasswordView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class ResettingPasswordView: UIView {
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
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("Send Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
        button.layer.cornerRadius = 10
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
// MARK: - Configure
private extension ResettingPasswordView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(emailField)
        addSubview(sendButton)
        addSubview(loadingIndicator)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            sendButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
// MARK: - Public Config
extension ResettingPasswordView {
    public func sendButtonValid(_ valid: Bool) {
        sendButton.layer.shadowColor = UIColor.black.cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        sendButton.layer.shadowRadius = valid ? 6.0 : 0
        sendButton.layer.shadowOpacity = valid ? 1.0 : 0
        sendButton.backgroundColor = .darkColour.withAlphaComponent(valid ? 1.0 : 0.6)
    }
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
