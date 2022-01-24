//
//  AMRAPExerciseView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AMRAPExerciseView: UIView {
    
    // MARK: - Subviews
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textAlignment = .center
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 100)
        label.textColor = .darkColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 40)
        label.textColor = .darkColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var doneButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.font
        button.setTitle("DONE", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.darkGray, for: .disabled)
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
private extension AMRAPExerciseView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 20
        addSubview(exerciseLabel)
        addSubview(topDividerView)
        addSubview(repLabel)
        addSubview(weightLabel)
        addSubview(bottomDividerView)
        addSubview(doneButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            exerciseLabel.topAnchor.constraint(equalTo: topAnchor),
            exerciseLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            exerciseLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            exerciseLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            
            topDividerView.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 2),
            topDividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            topDividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            repLabel.topAnchor.constraint(equalTo: topDividerView.bottomAnchor, constant: 10),
            repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            weightLabel.topAnchor.constraint(equalTo: repLabel.bottomAnchor, constant: 10),
            weightLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            bottomDividerView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),
            bottomDividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            bottomDividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}

// MARK: - Configure
extension AMRAPExerciseView {
    public func configure(with exercise: ExerciseModel) {
        exerciseLabel.text = exercise.exercise
        repLabel.text = exercise.reps[0].description
        weightLabel.text = exercise.weight[0]
    }
}
