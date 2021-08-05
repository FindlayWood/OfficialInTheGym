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
    
    var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("X", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var countDownButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("C", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var flipCameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("F", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var maxVideoLength = 20
    var minVideoLength = 10
    var currentVideoLength: videoLength = .long
    
    var videoLengthButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("20", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var recordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.alpha = 0.6
        button.layer.borderWidth = 5
        button.layer.borderColor = Constants.lightColour.cgColor
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var countDownNumber: Int = 10
    var timer = Timer()
    
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
        stackView.addArrangedSubview(videoLengthButton)
        stackView.addArrangedSubview(flipCameraButton)
        addSubview(stackView)
        //addSubview(backButton)
        //addSubview(countDownButton)
        //addSubview(videoLengthButton)
        //addSubview(flipCameraButton)
        addSubview(recordButton)
        addSubview(countDownLabel)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            countDownButton.widthAnchor.constraint(equalToConstant: 40),
            countDownButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoLengthButton.widthAnchor.constraint(equalToConstant: 40),
            videoLengthButton.heightAnchor.constraint(equalToConstant: 40),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 40),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            countDownLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countDownLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        ])
    }
    
    func setUIRecording() {
        recordButton.isHidden = false
        recordButton.backgroundColor = .red
        recordButton.alpha = 1
        recordButton.layer.borderColor = UIColor.red.cgColor
        backButton.isHidden = true
        countDownButton.isHidden = true
        videoLengthButton.isHidden = true
        flipCameraButton.isHidden = true
    }
    
    func setUICountdownOn() {
        backButton.isHidden = true
        countDownButton.isHidden = true
        videoLengthButton.isHidden = true
        flipCameraButton.isHidden = true
        recordButton.isHidden = true
    }
    
    func setUIDefault() {
        recordButton.isHidden = false
        recordButton.backgroundColor = .white
        recordButton.alpha = 0.6
        recordButton.layer.borderColor = Constants.lightColour.cgColor
        backButton.isHidden = false
        countDownButton.isHidden = false
        videoLengthButton.isHidden = false
        flipCameraButton.isHidden = false
    }
    
    func toggleCountDownUI(isOn: Bool) {
        if isOn {
            countDownButton.backgroundColor = .green
        } else {
            countDownButton.backgroundColor = .red
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
    
    func changeVideoLength() {
        if currentVideoLength == .long {
            currentVideoLength = .short
            videoLengthButton.setTitle(Int(currentVideoLength.rawValue).description, for: .normal)
        } else {
            currentVideoLength = .long
            videoLengthButton.setTitle(Int(currentVideoLength.rawValue).description, for: .normal)
        }
    }
}
