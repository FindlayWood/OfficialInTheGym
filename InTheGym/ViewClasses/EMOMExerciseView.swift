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
        label.font = UIFont(name: "Menlo-Bold", size: 70)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
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
        addSubview(repLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            exerciseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            exerciseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            repLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 20),
            repLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Public Configuartion
extension EMOMExerciseView {
    func configure(with exercise: exercise) {
        guard let name = exercise.exercise,
              let rep = exercise.reps
        else {
            return
        }
        exerciseLabel.text = name
        repLabel.text = rep.description + " reps"
    }
}
