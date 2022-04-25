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
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.text = "5"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exerciseCountIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "dumbbell_icon")
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stackOne: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [exerciseCountLabel,exerciseCountIcon])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Stack View Two
    var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "clock_icon")
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stackTwo: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel,timeIcon])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Stack View Three
    var rpeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.text = "8"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var rpeIcon: UILabel = {
        let label = UILabel()
        label.text = "RPE"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stackThree: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rpeLabel,rpeIcon])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stackOne, stackTwo, stackThree])
        stack.axis = .horizontal
        stack.spacing = 32
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
        backgroundColor = .thirdColour
        addSubview(hstack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: hstack)
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
