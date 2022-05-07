//
//  AddGroupWorkoutTypeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddGroupWorkoutTypeView: UIView {
    //MARK: - Properties
    let buttonHeight: CGFloat = 65
    
    let newText = "Create a new workout from scratch to add to this group."
    let savedText = "Choose a workout that you have saved to add to this group."
    
    // MARK: - Subviews
    /// button to add a new workout
    var newWorkoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 28)
        button.backgroundColor = .lightColour
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    /// textview to explain new workout button
    lazy var newWorkoutTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textColor = .darkGray
        view.text = newText
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// button to add a saved workout
    var savedWorkoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Saved Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 28)
        button.backgroundColor = .lightColour
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    /// textview to explain saved workout button
    lazy var savedWorkoutTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textColor = .darkGray
        view.text = savedText
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: -Initialzer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

private extension AddGroupWorkoutTypeView {
    func setupUI() {
        backgroundColor = .white
        addSubview(newWorkoutButton)
        addSubview(newWorkoutTextView)
        addSubview(savedWorkoutButton)
        addSubview(savedWorkoutTextView)
        constrainUI()
        
    }
    func constrainUI() {
        NSLayoutConstraint.activate([newWorkoutButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                                     newWorkoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     newWorkoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     newWorkoutButton.heightAnchor.constraint(equalToConstant: buttonHeight),
                                     
                                     newWorkoutTextView.topAnchor.constraint(equalTo: newWorkoutButton.bottomAnchor, constant: 5),
                                     newWorkoutTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     newWorkoutTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
                                     savedWorkoutButton.topAnchor.constraint(equalTo: newWorkoutTextView.bottomAnchor, constant: 20),
                                     savedWorkoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     savedWorkoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     savedWorkoutButton.heightAnchor.constraint(equalToConstant: buttonHeight),
                                     
                                     savedWorkoutTextView.topAnchor.constraint(equalTo: savedWorkoutButton.bottomAnchor, constant: 5),
                                     savedWorkoutTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     savedWorkoutTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
}
