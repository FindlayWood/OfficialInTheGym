//
//  AddCustomWorkloadView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddCustomWorkloadView: UIView {
    // MARK: - Properties
    var ratingSelected = PassthroughSubject<Int,Never>()
    // MARK: - Subviews
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "Account Created")
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "Enter workload for a session that was not recorded on this app. This could include sport matches, fitness sessions, hikes etc. You do NOT need to manually enter workload for sessions that are recorded on the app, these are added automatically."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var durationTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "enter duration (minutes)..."
        view.textColor = .label
        view.backgroundColor = .secondarySystemBackground
        view.font = .systemFont(ofSize: 32, weight: .medium)
        view.tintColor = .darkColour
        view.keyboardType = .numberPad
        view.addToolBar()
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var rpeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Enter the RPE (rate of perceived exertion) for this session. 1 = very very easy, 10 = extremely difficult, could not have done any more."
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
private extension AddCustomWorkloadView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(dismissButton)
        addSubview(addButton)
        addSubview(imageView)
        addSubview(messageLabel)
        addSubview(durationTextField)
        addSubview(stack)
        addSubview(rpeLabel)
        configureUI()
        addButtons()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            addButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            durationTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 64),
            durationTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            durationTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            
            stack.topAnchor.constraint(equalTo: durationTextField.bottomAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            rpeLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            rpeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            rpeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            messageLabel.topAnchor.constraint(equalTo: rpeLabel.bottomAnchor, constant: 32),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
        ])
    }
    func addButtons(_ selectedIndex: Int? = nil) {
        for view in stack.arrangedSubviews {
            view.removeFromSuperview()
        }
        for i in 1...10 {
            let newButton = UIButton()
            newButton.layer.borderColor = Constants.rpeColors[i - 1].cgColor
            newButton.layer.borderWidth = 1
            newButton.setTitle(i.description, for: .normal)
            if selectedIndex == i {
                newButton.backgroundColor = Constants.rpeColors[i - 1]
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
