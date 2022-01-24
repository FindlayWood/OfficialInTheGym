//
//  EMOMExerciseView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class EMOMExerciseView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dividerView: UIView = {
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
private extension EMOMExerciseView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 20
        addSubview(exerciseLabel)
        addSubview(dividerView)
        addSubview(repLabel)
        addSubview(weightLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseLabel.topAnchor.constraint(equalTo: topAnchor),
            exerciseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            exerciseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            exerciseLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            
            dividerView.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 5),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),

            repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            //repLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            repLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
            //repLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            weightLabel.topAnchor.constraint(equalTo: repLabel.bottomAnchor, constant: 10),
            weightLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            //repLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public Configuartion
extension EMOMExerciseView {
    func configure(with exercise: ExerciseModel) {
        let name = exercise.exercise
        let rep = exercise.reps[0]
        let weight = exercise.weight[0]
        exerciseLabel.text = name
        repLabel.text = rep.description
        weightLabel.text = weight
    }
}
