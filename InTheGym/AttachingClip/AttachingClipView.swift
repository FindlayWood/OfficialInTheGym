//
//  AttachingClipView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AttachingClipView: UIView {
    
    private lazy var originPoint = originalFrame.origin
    private let originalFrame = CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: Constants.screenSize.height * 0.25)
    
    // MARK: - Subviews
    var dismissView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.heightAnchor.constraint(equalToConstant: 5).isActive = true
        view.layer.cornerRadius = 2.5
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var newClipButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Clip", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = Constants.font
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var savedClipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Saved Clip", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = Constants.font
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup
private extension AttachingClipView {
    func setupUI() {
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundColor = .white
        clipsToBounds = true
        addSubview(dismissView)
        stack.addArrangedSubview(newClipButton)
        stack.addArrangedSubview(savedClipButton)
        addSubview(stack)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            dismissView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dismissView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            stack.topAnchor.constraint(equalTo: dismissView.bottomAnchor, constant: 30),
            stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            newClipButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            newClipButton.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.06),
            savedClipButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            savedClipButton.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.06),
        ])
    }
}

