//
//  AMRAPCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AMRAPCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "AMRAPCellID"
    
    // MARK: - Subviews
    var exerciseName: UILabel = {
       let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var repLabel: UILabel = {
       let label = UILabel()
        label.textColor = Constants.darkColour
        label.font = Constants.font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        backgroundColor = Constants.offWhiteColour
        layer.cornerRadius = 10
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Setup UI
private extension AMRAPCell {
    
    func setup() {
        addSubview(exerciseName)
        addSubview(repLabel)
        constrain()
    }
    
    func constrain() {
        NSLayoutConstraint.activate([exerciseName.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     repLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        
                                     exerciseName.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 20),
                                     repLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        
                                     exerciseName.trailingAnchor.constraint(equalTo: repLabel.leadingAnchor, constant: -5)])
    }
}

// MARK: - Public Configuration
extension AMRAPCell {
    public func configure(with exercise: ExerciseModel) {
        exerciseName.text = exercise.exercise
        repLabel.text = exercise.reps?.description
    }
}
