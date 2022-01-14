//
//  WorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

// MARK: - Workout Table View Cell
/// The cell for a workout that can be completed
/// Will only appear in a users personal workout page

import Foundation
import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let cellID = "WorkoutTableViewCellID"
    
    // MARK: - Subviews
        // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var creatorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var exerciseCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        // ICONS
    lazy var creatorIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "coach_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var exerciseIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dumbbell_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup
private extension WorkoutTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        addSubview(titleLabel)
        addSubview(creatorLabel)
        addSubview(exerciseCountLabel)
        addSubview(creatorIcon)
        addSubview(exerciseIcon)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            creatorIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 5),
            creatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 10),
            exerciseIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseCountLabel.centerYAnchor),
            exerciseCountLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 5),
            exerciseCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Configure
extension WorkoutTableViewCell {
    public func configure(with data: GroupWorkoutModel) {
        titleLabel.text = data.title
        creatorLabel.text = data.createdBy
        exerciseCountLabel.text = data.exercises?.count.description
    }
    
    public func configure(with data: WorkoutModel) {
        titleLabel.text = data.title
        creatorLabel.text = data.createdBy
        exerciseCountLabel.text = data.exercises?.count.description
    }
    
    public func configure(with data: SavedWorkoutModel) {
        titleLabel.text = data.title
        creatorLabel.text = data.createdBy
        var totalExerciseCount = 0
        totalExerciseCount += data.exercises?.count ?? 0
        totalExerciseCount += data.circuits?.count ?? 0
        totalExerciseCount += data.emoms?.count ?? 0
        totalExerciseCount += data.amraps?.count ?? 0
        exerciseCountLabel.text = totalExerciseCount.description
    }
}
