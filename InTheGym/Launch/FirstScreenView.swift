//
//  FirstScreenView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class FirstScreenView: UIView {
    
    private let fontName = "Menlo-Bold"
    private let slogan = "Create and Share Workouts"
    private let loginString = "Aleady have an account?"
    
    var centerImage: UIImageView = {
       let imageview = UIImageView()
        imageview.image = UIImage(named: "inthegym_icon3")
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "INTHEGYM"
        label.textColor = Constants.lightColour
        label.font = UIFont(name: fontName, size: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var sloganMessage: UILabel = {
        let label = UILabel()
        label.text = slogan
        label.font = UIFont(name: "Menlo-BoldItalic", size: 50)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bottomView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var signUpButton: UIButton = {
       let button = UIButton()
        button.setTitle("SIGN UP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: fontName, size: 25)
        button.layer.cornerRadius = 30
        button.backgroundColor = Constants.darkColour
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        button.layer.shadowRadius = 6.0
        button.layer.shadowOpacity = 1.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginMessage: UILabel = {
       let label = UILabel()
        label.text = loginString
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = UIFont(name: fontName, size: 15)
//        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        addSubview(centerImage)
        addSubview(titleLabel)
        addSubview(sloganMessage)
        //addSubview(bottomView)
        addSubview(signUpButton)
        bottomStack.addArrangedSubview(loginMessage)
        bottomStack.addArrangedSubview(loginButton)
        addSubview(bottomStack)
//        addSubview(loginMessage)
//        addSubview(loginButton)
//        bottomView.addSubview(signUpButton)
//        bottomView.addSubview(loginMessage)
//        bottomView.addSubview(loginButton)
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([
                                     //titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: centerImage.bottomAnchor),
                                     
                                     centerImage.topAnchor.constraint(equalTo: topAnchor, constant: Constants.screenSize.height * 0.1),
                                     //centerImage.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 10),
                                     centerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     centerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     centerImage.heightAnchor.constraint(equalTo: centerImage.widthAnchor),
        
                                     sloganMessage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                                     sloganMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     sloganMessage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     
//                                     bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
//                                     bottomView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
//                                     bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
//                                     bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     
                                     signUpButton.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -20),
                                     signUpButton.heightAnchor.constraint(equalToConstant: 60),
                                     signUpButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     signUpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
                                     bottomStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
                                     bottomStack.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     //bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     //bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
//                                     loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//                                     loginButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
                                     loginButton.heightAnchor.constraint(equalToConstant: 30),
        
//                                     loginMessage.trailingAnchor.constraint(equalTo: loginButton.leadingAnchor, constant: -10),
//                                     loginMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//                                     loginMessage.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }
}
