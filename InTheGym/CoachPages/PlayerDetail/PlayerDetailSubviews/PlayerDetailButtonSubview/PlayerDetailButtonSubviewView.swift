//
//  PlayerDetailButtonSubviewView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerDetailButtonSubviewView: UIView {
    // MARK: - Subviews
    var viewWorkoutsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("View Player Workouts", for: .normal)
        button.setTitleColor(.label, for: .normal)
//        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var addWorkoutsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("Add Workout", for: .normal)
        button.setTitleColor(.label, for: .normal)
//        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [viewWorkoutsButton,addWorkoutsButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
private extension PlayerDetailButtonSubviewView {
    func setupUI() {
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
