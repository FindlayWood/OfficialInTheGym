//
//  JumpMeasuringView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class JumpMeasuringView: UIView {
    
    // MARK: - Properties
    var currentVideoLength: Int = 30
    
    var countDownNumber: Int = 10
    var timer = Timer()
    
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
        button.layer.borderColor = Constants.darkColour.cgColor
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var countDownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Menlo-Bold", size: 75)
        label.textAlignment = .center
        label.isHidden = true
        label.text = countDownNumber.description
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
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}
private extension JumpMeasuringView {
    func setupUI() {
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(countDownButton)
        stackView.addArrangedSubview(flipCameraButton)
        addSubview(stackView)
        addSubview(messageLabel)
        addSubview(recordButton)
        addSubview(countDownLabel)
        constrainUI()
    }
    func constrainUI() {
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
            countDownLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
        
        ])
    }
}
extension JumpMeasuringView {
    func setUIRecording() {
        countDownLabel.isHidden = true
        recordButton.isHidden = false
        recordButton.backgroundColor = .red
        recordButton.alpha = 1
        recordButton.layer.borderColor = UIColor.red.cgColor
        stackView.isHidden = true
    }
    
    func setUICountdownOn() {
        countDownLabel.isHidden = false
        stackView.isHidden = true
        recordButton.isHidden = true
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
    
    func startCountDown() {
        countDownLabel.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountDownLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountDownLabel() {
        if countDownNumber > 0 {
            countDownNumber -= 1
            countDownLabel.text = countDownNumber.description
        } else {
            timer.invalidate()
            countDownLabel.isHidden = true
            countDownNumber = 10
            countDownLabel.text = countDownNumber.description
        }
    }
    func setCountDown(to number: Int) {
        countDownLabel.isHidden = false
        countDownLabel.text = number.description
    }
}
