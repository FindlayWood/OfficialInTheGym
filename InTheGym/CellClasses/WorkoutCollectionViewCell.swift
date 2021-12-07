//
//  WorkoutCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let reuseID = "WorkoutCollectionViewCellReuseID"
    
    // MARK: - Subviews
    // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
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
    var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var completedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
//        label.font = .boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .right
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
    var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
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
// MARK: - Configure
private extension WorkoutCollectionViewCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        contentView.addSubview(titleLabel)
        contentView.addSubview(completedLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(exerciseCountLabel)
        contentView.addSubview(creatorIcon)
        contentView.addSubview(exerciseIcon)
        contentView.addSubview(clockIcon)
        contentView.addSubview(timeLabel)
        contentView.addSubview(scoreLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            completedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            completedLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            completedLabel.widthAnchor.constraint(equalToConstant: 112),
            
            //titleLabel.widthAnchor.constraint(equalToConstant: Constants.screenSize.width - 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: completedLabel.leadingAnchor, constant: -5),
            
            
            
            //creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            creatorIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 5),
            creatorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 10),
            exerciseIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseCountLabel.centerYAnchor),
            exerciseCountLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 5),
            //exerciseCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            timeLabel.topAnchor.constraint(equalTo: exerciseCountLabel.bottomAnchor, constant: 10),
            clockIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            clockIcon.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: clockIcon.trailingAnchor, constant: 5),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            clockIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            scoreLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor)
        ])
    }
}

extension WorkoutCollectionViewCell {
    public func configure(with model: WorkoutModel) {
        titleLabel.text = model.title
        creatorLabel.text = model.createdBy
        exerciseCountLabel.text = model.exercises.count.description
        if let time = model.timeToComplete {
            timeLabel.text = time.convertToWorkoutTime()
        } else {
            timeLabel.isHidden = true
            clockIcon.isHidden = true
        }
        if model.completed {
            completedLabel.textColor = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
            completedLabel.text = "COMPLETED"
        } else if model.liveWorkout ?? false {
            completedLabel.text = "LIVE"
            completedLabel.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        } else if model.startTime != nil {
            completedLabel.text = "IN PROGRESS"
            completedLabel.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        } else {
            completedLabel.textColor = #colorLiteral(red: 0.8643916561, green: 0.1293050488, blue: 0.007468156787, alpha: 1)
            completedLabel.text = "NOT STARTED"
        }
        if let score = model.score {
            scoreLabel.text = "Score: \(score)"
            scoreLabel.isHidden = false
        } else {
            scoreLabel.isHidden = true
        }
    }
}
