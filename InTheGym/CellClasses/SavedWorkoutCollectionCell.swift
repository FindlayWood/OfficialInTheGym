//
//  SavedWorkoutCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

// MARK: - Workout Table View Cell
/// The cell for a workout that can be completed
/// Will only appear in a users personal workout page
import Foundation
import UIKit

class SavedWorkoutCollectionCell: FullWidthCollectionViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let reuseID = "SavedWorkoutCollectionCellreuseID"
    
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
    var averageTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var averageRPEScoreLabel: UILabel = {
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
    lazy var clockIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "clock_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var privacyIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "clock_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

// MARK: - Setup
private extension SavedWorkoutCollectionCell {
    func setupUI() {
//        backgroundColor = .offWhiteColour
//        layer.cornerRadius = 10
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(creatorLabel)
//        contentView.addSubview(exerciseCountLabel)
//        contentView.addSubview(averageTimeLabel)
//        contentView.addSubview(averageRPEScoreLabel)
//        contentView.addSubview(creatorIcon)
//        contentView.addSubview(exerciseIcon)
//        contentView.addSubview(clockIcon)
//        contentView.addSubview(privacyIcon)
//        addViewShadow(with: .darkColour)
//        constrainUI()
        backgroundColor = .offWhiteColour
        addViewShadow(with: .darkColour)
        layer.cornerRadius = 10
        contentView.addSubview(workoutView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            titleLabel.trailingAnchor.constraint(equalTo: privacyIcon.leadingAnchor, constant: -5),
//            
//            creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            creatorIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
//            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 5),
//            creatorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            
//            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 10),
//            exerciseIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseCountLabel.centerYAnchor),
//            exerciseCountLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 5),
//            
//            averageTimeLabel.topAnchor.constraint(equalTo: exerciseCountLabel.bottomAnchor, constant: 10),
//            clockIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            clockIcon.centerYAnchor.constraint(equalTo: averageTimeLabel.centerYAnchor),
//            averageTimeLabel.leadingAnchor.constraint(equalTo: clockIcon.trailingAnchor, constant: 5),
//            averageTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            
//            averageRPEScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            averageRPEScoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            
//            privacyIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            privacyIcon.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            
            workoutView.topAnchor.constraint(equalTo: contentView.topAnchor),
            workoutView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            workoutView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            workoutView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: - Configure
extension SavedWorkoutCollectionCell {
    
    public func configure(with data: SavedWorkoutModel) {
        workoutView.configure(with: data)
//        titleLabel.text = data.title
//        creatorLabel.text = data.createdBy
//        averageTimeLabel.text = data.averageTime()
//        averageRPEScoreLabel.text = data.averageScore().description
//        exerciseCountLabel.text = data.totalExerciseCount().description
//        privacyIcon.image = data.isPrivate ? UIImage(named: "locked_icon") : UIImage(named: "public_icon")
    }
}

