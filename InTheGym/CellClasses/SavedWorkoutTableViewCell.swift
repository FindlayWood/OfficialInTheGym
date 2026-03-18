//
//  SavedWorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation



// MARK: - Workout Table View Cell
/// The cell for a workout that can be completed
/// Will only appear in a users personal workout page

import UIKit

class SavedWorkoutTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let cellID = "SavedWorkoutTableViewCellID"
    
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
    
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.contentView.frame.insetBy(dx: 10, dy: 10)
    }
}

// MARK: - Setup
private extension SavedWorkoutTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        contentView.addSubview(titleLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(exerciseCountLabel)
        contentView.addSubview(averageTimeLabel)
        contentView.addSubview(averageRPEScoreLabel)
        contentView.addSubview(creatorIcon)
        contentView.addSubview(exerciseIcon)
        contentView.addSubview(clockIcon)
        contentView.addSubview(privacyIcon)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: privacyIcon.leadingAnchor, constant: -5),
            
            creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            creatorIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 5),
            creatorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 10),
            exerciseIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseCountLabel.centerYAnchor),
            exerciseCountLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 5),
//            exerciseCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            
            averageTimeLabel.topAnchor.constraint(equalTo: exerciseCountLabel.bottomAnchor, constant: 10),
            clockIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            clockIcon.centerYAnchor.constraint(equalTo: averageTimeLabel.centerYAnchor),
            averageTimeLabel.leadingAnchor.constraint(equalTo: clockIcon.trailingAnchor, constant: 5),
            averageTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            averageRPEScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            averageRPEScoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            privacyIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            privacyIcon.topAnchor.constraint(equalTo: titleLabel.topAnchor)
        ])
    }
}

// MARK: - Configure
extension SavedWorkoutTableViewCell {
    
    public func configure(with data: SavedWorkoutModel) {
        titleLabel.text = data.title
        averageTimeLabel.text = data.averageTime()
        averageRPEScoreLabel.text = data.averageScore().description
        exerciseCountLabel.text = data.totalExerciseCount().description
        privacyIcon.image = data.isPrivate ? UIImage(named: "locked_icon") : UIImage(named: "public_icon")
    }
}
