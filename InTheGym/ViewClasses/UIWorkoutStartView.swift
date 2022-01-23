//
//  UIWorkoutStartView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class UIWorkoutStartView: UIView {
    // MARK: - Publisher
    var readyToStartWorkout = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var newHeightAnchor: NSLayoutConstraint!
    var flashLabel = UILabel()
    var flashView = UIView()
    var bottomViewSetUpClosure: (() -> ())?
    var title: String?

    // MARK: - Subviews
    var beginButton: UIButton = {
        let beginButton = UIButton()
        beginButton.setTitle("Begin Workout", for: .normal)
        beginButton.backgroundColor = .darkColour
        beginButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 31)
        beginButton.layer.cornerRadius = 24.5
        // add shadows to the add button
        beginButton.layer.shadowColor = UIColor.darkGray.cgColor
        beginButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        beginButton.layer.shadowRadius = 6.0
        beginButton.layer.shadowOpacity = 1.0
        beginButton.layer.masksToBounds = false
        beginButton.addTarget(self, action: #selector(beginPressed(_:)), for: .touchUpInside)
        beginButton.translatesAutoresizingMaskIntoConstraints = false
        return beginButton
    }()
    var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "Timer will begin on button click."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var scrollLabel: UILabel = {
        let label = UILabel()
        label.text = "Scroll to view exercises."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Stage 2 Subviews
    var readyLabel: UILabel = {
        let label = UILabel()
        label.text = "ARE YOU READY TO BEGIN?"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("CONTINUE", for: .normal)
        button.backgroundColor = .darkColour
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 31)
        button.layer.cornerRadius = 24.5
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        button.layer.shadowRadius = 6.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(continuePressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel", for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Stage 3
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.text = title
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
    // MARK: - Setup UI
private extension UIWorkoutStartView {
    
    func setupUI() {
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        newHeightAnchor = self.heightAnchor.constraint(equalToConstant: 0)
        backgroundColor = .white
        stack.addArrangedSubview(beginButton)
        stack.addArrangedSubview(timerLabel)
        stack.addArrangedSubview(scrollLabel)
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            newHeightAnchor,
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            beginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            beginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            beginButton.heightAnchor.constraint(equalToConstant: 49)
        ])
        
        newHeightAnchor.isActive = false
        newHeightAnchor = heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.25)
        newHeightAnchor.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func beginPressed(_ sender: UIButton) {
        stack.isHidden = true
        beginButton.isHidden = true
        timerLabel.isHidden = true
        scrollLabel.isHidden = true
        stack.removeArrangedSubview(beginButton)
        stack.removeArrangedSubview(timerLabel)
        stack.removeArrangedSubview(scrollLabel)
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.45)
        newHeightAnchor?.isActive = true
        stack.addArrangedSubview(readyLabel)
        stack.addArrangedSubview(continueButton)
        //stack.isHidden = false
        addSubview(cancelButton)
        cancelButton.isHidden = true
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
        ])
        
        UIView.animate(withDuration: 0.5) {
            self.superview?.layoutIfNeeded()
        } completion: { (_) in
            self.stack.isHidden = false
            self.cancelButton.isHidden = false
        }
    }
    
    @objc func continuePressed(_ sender: UIButton) {
        stack.isHidden = true
        
        newHeightAnchor.isActive = false
        newHeightAnchor = heightAnchor.constraint(equalToConstant: Constants.screenSize.height)
        newHeightAnchor.isActive = true
        
        addSubview(titleLabel)
        titleLabel.isHidden = true
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        UIView.animate(withDuration: 0.5) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.titleLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.readyToStartWorkout.send(())
            }
        }
    }
}
