//
//  SignUpTextFieldView.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpTextFieldView: UIView {
    // MARK: - Properties
//    var isSecure: Bool = false
//    var textFieldPlaceHolder: String
//    var errorPrompt: String
    
    let imageDiemsion: CGFloat = 20
    let inValidImage = UIImage(named: "alert_icon")
    let validImage = UIImage(named: "tick_icon")
    
    // MARK: - Subviews
    lazy var textFieldView: SkyFloatingLabelTextField = {
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
        field.selectedTitleColor = .darkColour
        field.selectedLineColor = .darkColour
        field.clearButtonMode = .never
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .red.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: imageDiemsion).isActive = true
        view.widthAnchor.constraint(equalToConstant: imageDiemsion).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var checkingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.heightAnchor.constraint(equalToConstant: imageDiemsion).isActive = true
        view.widthAnchor.constraint(equalToConstant: imageDiemsion).isActive = true
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
private extension SignUpTextFieldView {
    func setupUI() {
        addSubview(textFieldView)
        addSubview(promptLabel)
        addSubview(imageView)
        addSubview(checkingIndicator)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textFieldView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textFieldView.topAnchor.constraint(equalTo: topAnchor),
            textFieldView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -5),
            textFieldView.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor),
            
            promptLabel.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 2),
            promptLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            promptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            checkingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkingIndicator.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor)
        ])
    }
}

extension SignUpTextFieldView {
    public func configure(isSecure: Bool, textFieldPlaceHolder: String, errorPrompt: String) {
        textFieldView.isSecureTextEntry = isSecure
        textFieldView.placeholder = textFieldPlaceHolder
        textFieldView.title = textFieldPlaceHolder
        textFieldView.selectedTitle = textFieldPlaceHolder
        promptLabel.text = errorPrompt
    }
    public func changeState(to state: SignUpValidState) {
        switch state {
        case .notEnoughInfo:
            imageView.isHidden = true
            promptLabel.isHidden = true
            checkingIndicator.stopAnimating()
        case .inValidInfo:
            imageView.isHidden = false
            imageView.image = inValidImage
            promptLabel.isHidden = false
            checkingIndicator.stopAnimating()
        case .valid:
            imageView.isHidden = false
            imageView.image = validImage
            promptLabel.isHidden = true
            checkingIndicator.stopAnimating()
        case .checking:
            imageView.isHidden = true
            promptLabel.isHidden = true
            checkingIndicator.startAnimating()
        }
    }
}

enum SignUpValidState {
    case notEnoughInfo
    case inValidInfo
    case valid
    case checking
}
