//
//  OtherExerciseView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class OtherExerciseView: UIView {
    
    // MARK: - Properties
    let messageText = "Make sure you have checked that the exercise you are looking for is not in the app. Using exercises already in the app makes it easier to record exercise data. If it does not exist enter the exercise name above, if you have previously entered the exercise - make sure to enter it exactly the same (they are case sensitive) to keep your stats accurate. We keep a track of all exercises entered manually to help us add more exercises to the app."
    
    // MARK: - Subview
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "situps")
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exerciseTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "enter exercise name..."
        view.textColor = .label
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.font = .systemFont(ofSize: 18, weight: .semibold)
        view.autocapitalizationType = .words
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var message: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.text = messageText
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textColor = .secondaryLabel
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.secondarySystemBackground, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension OtherExerciseView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(imageView)
        addSubview(exerciseTextField)
        addSubview(message)
        addSubview(continueButton)
        addSubview(cancelButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            cancelButton.widthAnchor.constraint(equalToConstant: 50),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            message.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            message.centerXAnchor.constraint(equalTo: centerXAnchor),
            message.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            exerciseTextField.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 8),
            exerciseTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            exerciseTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            exerciseTextField.heightAnchor.constraint(equalToConstant: 40),
            

        ])
    }
}
// MARK: - Public Config
extension OtherExerciseView {
    public func setContinueButton(to enabled: Bool) {
        continueButton.isEnabled = enabled
        continueButton.isUserInteractionEnabled = enabled
    }
}
