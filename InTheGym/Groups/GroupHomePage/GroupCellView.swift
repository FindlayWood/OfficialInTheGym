//
//  GroupCellView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupCellView: UIView {
    
    // MARK: - Subviews
    var numberButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.font
        button.setTitleColor(.darkColour, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var textButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.font
        button.setTitleColor(.darkColour, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.isUserInteractionEnabled = false
        stack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
}

// MARK: - Setup
private extension GroupCellView {
    func setUpUI() {
        backgroundColor = .clear
        stackView.addArrangedSubview(numberButton)
        stackView.addArrangedSubview(textButton)
        addSubview(stackView)
        constrainUI()
        
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
                                     stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     stackView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Configure Buttons
extension GroupCellView {
    public func configure(with number: Int, and text: String) {
        numberButton.setTitle(number.description, for: .normal)
        textButton.setTitle(text, for: .normal)
    }
}
