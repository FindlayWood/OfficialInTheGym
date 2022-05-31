//
//  MyWorkoutStatsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyWorkoutStatsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var totalWorkoutsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "43"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalWorkoutsSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Workouts Completed"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "47h 31m"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalTimeSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Total Workout Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var scoreContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workloadContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var lastThreeScoresContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension MyWorkoutStatsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(totalWorkoutsLabel)
        addSubview(totalWorkoutsSubLabel)
        addSubview(totalTimeLabel)
        addSubview(totalTimeSubLabel)
        addSubview(scoreContainerView)
        addSubview(workloadContainerView)
        addSubview(lastThreeScoresContainerView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            totalWorkoutsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            totalWorkoutsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalWorkoutsLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            totalWorkoutsSubLabel.topAnchor.constraint(equalTo: totalWorkoutsLabel.bottomAnchor),
            totalWorkoutsSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalWorkoutsSubLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            totalTimeLabel.topAnchor.constraint(equalTo: totalWorkoutsLabel.bottomAnchor, constant: 16),
            totalTimeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            totalTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTimeSubLabel.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor),
            totalTimeSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTimeSubLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            scoreContainerView.topAnchor.constraint(equalTo: totalTimeSubLabel.bottomAnchor, constant: 16),
            scoreContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scoreContainerView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            scoreContainerView.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.22),
            
            workloadContainerView.topAnchor.constraint(equalTo: totalTimeSubLabel.bottomAnchor, constant: 16),
            workloadContainerView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            workloadContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            workloadContainerView.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.22),
            
            lastThreeScoresContainerView.topAnchor.constraint(equalTo: scoreContainerView.bottomAnchor, constant: 16),
            lastThreeScoresContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lastThreeScoresContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            lastThreeScoresContainerView.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.12),
        ])
    }
}
// MARK: - Public Config
extension MyWorkoutStatsView {
    public func configure(with model: MyWorkoutStatsModel) {
        totalWorkoutsLabel.text = model.totalWorkoutsComplete.description
        totalTimeLabel.text = model.totalWorkoutTime.convertToWorkoutTime()
    }
}
