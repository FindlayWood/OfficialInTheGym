//
//  ExerciseRatingView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseRatingView: UIView {
    // MARK: - Publishers
    var ratingSelected = PassthroughSubject<Int,Never>()
    // MARK: - Properties
    
    // MARK: - Subviews
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .darkColour
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var currentRatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "9.4"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Choose a rating for this exercise. (10 = the best, 1 = the worst)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit Rating", for: .normal)
        button.backgroundColor = .darkColour
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 8
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
// MARK: - Configure
private extension ExerciseRatingView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(dismissButton)
        addSubview(loadingIndicator)
        addSubview(currentRatingLabel)
        addSubview(stack)
        addSubview(messageLabel)
        addSubview(submitButton)
        configureUI()
        addButtons()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            currentRatingLabel.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -16),
            currentRatingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            
            submitButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6)
        ])
    }
    func addButtons(_ selectedIndex: Int? = nil) {
        for view in stack.arrangedSubviews {
            view.removeFromSuperview()
        }
        for i in 1...10 {
            let newButton = UIButton()
            newButton.layer.borderColor = UIColor.darkColour.cgColor
            newButton.layer.borderWidth = 1
            newButton.setTitle(i.description, for: .normal)
            if selectedIndex == i {
                newButton.backgroundColor = .darkColour
                newButton.setTitleColor(.systemBackground, for: .normal)
            } else {
                newButton.setTitleColor(.darkColour, for: .normal)
                newButton.backgroundColor = .systemBackground
            }
            newButton.translatesAutoresizingMaskIntoConstraints = false
            newButton.layer.cornerRadius = 8
            newButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            stack.addArrangedSubview(newButton)
        }
    }
    @objc func buttonAction(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {return}
        guard let index = Int(buttonTitle) else {return}
        addButtons(index)
        ratingSelected.send(index)
    }
}
// MARK: - Public Config
extension ExerciseRatingView {
    public func setSubmitButton(to enabled: Bool) {
        submitButton.backgroundColor = enabled ? .darkColour : .darkColour.withAlphaComponent(0.5)
    }
}
