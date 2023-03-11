//
//  WorkoutViewHStack.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutViewHStack: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    // MARK: - Stack View One
    var exerciseCountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exerciseMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Exercises"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exerciseCountIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.image = UIImage(named: "dumbbell_icon")
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stackOne: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [exerciseCountLabel,exerciseMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Stack View Two
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Duration"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.image = UIImage(named: "clock_icon")
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stackTwo: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel,timeMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Stack View Three
    var rpeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "8"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var rpeMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "RPE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var rpeIcon: UILabel = {
        let label = UILabel()
        label.text = "RPE"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stackThree: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rpeLabel,rpeMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stackTwo, stackOne, stackThree])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
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
private extension WorkoutViewHStack {
    func setupUI() {
        addSubview(hstack)
        configureUI()
    }
    func configureUI() {
        let exerciseIconHeight = exerciseCountIcon.heightAnchor.constraint(equalToConstant: 30)
        exerciseIconHeight.priority = UILayoutPriority(999)
        let timeIconHeight = timeIcon.heightAnchor.constraint(equalToConstant: 30)
        timeIconHeight.priority = UILayoutPriority(999)
        let rpeLabelIcon = rpeIcon.heightAnchor.constraint(equalToConstant: 30)
        rpeLabelIcon.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            exerciseIconHeight,
            hstack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension WorkoutViewHStack {
    public func configure(with model: SavedWorkoutModel) {
        exerciseCountLabel.text = model.totalExerciseCount().description
        timeLabel.text = model.averageTime()
        rpeLabel.text = model.averageTime()
        if model.totalTime > 0 {
            stackTwo.isHidden = false
            timeLabel.text = model.averageTime()
        } else {
            stackTwo.isHidden = true
        }
        if model.totalRPE > 0 {
            stackThree.isHidden = false
            rpeLabel.text = model.averageScore().description
        } else {
            stackThree.isHidden = true
        }
    }
    public func configure(with model: WorkoutModel) {
        exerciseCountLabel.text = model.totalExerciseCount().description
        if let time = model.timeToComplete {
            stackTwo.isHidden = false
            timeLabel.text = time.convertToWorkoutTime()
        } else {
            stackTwo.isHidden = true
        }
        if let score = model.score {
            stackThree.isHidden = false
            rpeLabel.text = score.description
        } else {
            stackThree.isHidden = true
        }
    }
}
