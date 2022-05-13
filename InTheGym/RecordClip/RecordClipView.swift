//
//  RecordClipView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

enum videoLength: Double {
    case long = 20
    case short = 10
}

class RecordClipView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .darkColour
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var countDownButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "timer"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .darkColour
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var flipCameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .darkColour
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var recordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.alpha = 0.6
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.lightColour.cgColor
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var countDownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Menlo-Bold", size: 75)
        label.textAlignment = .center
        label.isHidden = true
        label.text = "10"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUpView() {
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(countDownButton)
        stackView.addArrangedSubview(flipCameraButton)
        addSubview(stackView)
        addSubview(recordButton)
        addSubview(countDownLabel)
        addSubview(messageLabel)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            countDownButton.widthAnchor.constraint(equalToConstant: 40),
            countDownButton.heightAnchor.constraint(equalToConstant: 40),
            
            flipCameraButton.widthAnchor.constraint(equalToConstant: 40),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            messageLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            countDownLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countDownLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        ])
    }
    
    func setUIRecording() {
        countDownLabel.isHidden = true
        recordButton.isHidden = false
        recordButton.backgroundColor = .red
        recordButton.alpha = 1
        recordButton.layer.borderColor = UIColor.red.cgColor
        stackView.isHidden = true
    }
    
    func setUICountdownOn() {
        stackView.isHidden = true
        recordButton.isHidden = true
        countDownLabel.isHidden = false
    }
    
    func setUIDefault() {
        countDownLabel.isHidden = true
        recordButton.isHidden = false
        recordButton.backgroundColor = .white
        recordButton.alpha = 0.6
        recordButton.layer.borderColor = UIColor.lightColour.cgColor
        stackView.isHidden = false
    }
    
    func toggleCountDownUI(isOn: Bool) {
        if isOn {
            countDownButton.backgroundColor = .lightColour
        } else {
            countDownButton.backgroundColor = .white
        }
        showMessage(countdown: isOn)
    }
    
    func showMessage(countdown: Bool) {
        if countdown {
            messageLabel.text = "10s countdown is on."
        } else {
            messageLabel.text = "10s countdown is off."
        }
        messageLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.messageLabel.isHidden = true
        }
    }
    func showMessage(maxVideoLength: Bool) {
        if maxVideoLength {
            messageLabel.text = "Max Video Length set to 20s."
        } else {
            messageLabel.text = "Max Video Length set to 10s."
        }
        messageLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.messageLabel.isHidden = true
        }
    }
    func setCountDown(to number: Int) {
        countDownLabel.text = number.description
    }

}
