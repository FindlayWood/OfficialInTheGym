//
//  ThinkingTimeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

final class ThinkingTimeView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "Thinking Time"
        label.font = UIFont(name: "Menlo-BoldItalic", size: 50)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.text = ThinkingTimeMessages.message
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dismiss", for: .normal)
        button.backgroundColor = .darkColour
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        button.layer.cornerRadius = 24.5
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        button.layer.shadowRadius = 6.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var dismissMessageLabel: UILabel = {
        let label = UILabel()
        label.text = ThinkingTimeMessages.dismissMessage
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension ThinkingTimeView {
    func setupUI()  {
        backgroundColor = .offWhiteColour
        addSubview(mainLabel)
        addSubview(messageLabel)
        addSubview(dismissButton)
        addSubview(dismissMessageLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            mainLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            dismissMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            dismissMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            dismissMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            dismissButton.bottomAnchor.constraint(equalTo: dismissMessageLabel.topAnchor, constant: -8),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dismissButton.heightAnchor.constraint(equalToConstant: 49)
        ])
    }
}
