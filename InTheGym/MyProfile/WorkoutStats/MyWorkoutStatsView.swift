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
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var allTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "All Time Stats"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalWorkoutsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
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
        label.text = "0m 0s"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
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
    var allTimeSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Workout Scores"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var scoreContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var scoresSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workloadContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var lastThreeScoresContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workloadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Workload"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var segment: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 40), buttonTitles: ["1 Week", "2 Weeks", "4 Weeks"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var totalWorkloadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalWorkloadSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Total Workload"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var filteredTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0m 0s"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var filteredTimeLabelSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Total Workout Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var allWorkloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("All Workloads", for: .normal)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension MyWorkoutStatsView {
    func setupUI() {
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground
        addSubview(scrollView)
        scrollView.addSubview(allTimeLabel)
        scrollView.addSubview(totalWorkoutsLabel)
        scrollView.addSubview(totalWorkoutsSubLabel)
        scrollView.addSubview(totalTimeLabel)
        scrollView.addSubview(totalTimeSubLabel)
        scrollView.addSubview(allTimeSeparatorView)
        scrollView.addSubview(scoreLabel)
        scrollView.addSubview(scoreContainerView)
        scrollView.addSubview(scoresSeparatorView)
        scrollView.addSubview(workloadContainerView)
        scrollView.addSubview(lastThreeScoresContainerView)
        scrollView.addSubview(workloadLabel)
        scrollView.addSubview(segment)
        scrollView.addSubview(totalWorkloadLabel)
        scrollView.addSubview(totalWorkloadSubLabel)
        scrollView.addSubview(filteredTimeLabel)
        scrollView.addSubview(filteredTimeLabelSubLabel)
        scrollView.addSubview(allWorkloadButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            allTimeLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            allTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            totalWorkoutsLabel.topAnchor.constraint(equalTo: allTimeLabel.bottomAnchor, constant: 8),
            totalWorkoutsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalWorkoutsLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            totalWorkoutsLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            totalWorkoutsSubLabel.topAnchor.constraint(equalTo: totalWorkoutsLabel.bottomAnchor),
            totalWorkoutsSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalWorkoutsSubLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            totalTimeLabel.topAnchor.constraint(equalTo: totalWorkoutsLabel.bottomAnchor, constant: 16),
            totalTimeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            totalTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTimeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            totalTimeSubLabel.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor),
            totalTimeSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTimeSubLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            allTimeSeparatorView.topAnchor.constraint(equalTo: totalTimeSubLabel.bottomAnchor, constant: 16),
            allTimeSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            allTimeSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            allTimeSeparatorView.heightAnchor.constraint(equalToConstant: 2),
            
            scoreLabel.topAnchor.constraint(equalTo: allTimeSeparatorView.bottomAnchor, constant: 32),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            scoreContainerView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            scoreContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            scoreContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            scoreContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            
            lastThreeScoresContainerView.topAnchor.constraint(equalTo: scoreContainerView.bottomAnchor, constant: 16),
            lastThreeScoresContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lastThreeScoresContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            lastThreeScoresContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            scoresSeparatorView.topAnchor.constraint(equalTo: lastThreeScoresContainerView.bottomAnchor, constant: 16),
            scoresSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scoresSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scoresSeparatorView.heightAnchor.constraint(equalToConstant: 2),
            
            workloadLabel.topAnchor.constraint(equalTo: scoresSeparatorView.bottomAnchor, constant: 32),
            workloadLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            segment.topAnchor.constraint(equalTo: workloadLabel.bottomAnchor, constant: 16),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor),
            segment.heightAnchor.constraint(equalToConstant: 40),
            
            workloadContainerView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 16),
            workloadContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            workloadContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            workloadContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            
            totalWorkloadLabel.topAnchor.constraint(equalTo: workloadContainerView.bottomAnchor, constant: 16),
            totalWorkloadLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalWorkloadLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            totalWorkloadLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            totalWorkloadSubLabel.topAnchor.constraint(equalTo: totalWorkloadLabel.bottomAnchor, constant: 8),
            totalWorkloadSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            filteredTimeLabel.topAnchor.constraint(equalTo: totalWorkloadSubLabel.bottomAnchor, constant: 16),
            filteredTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            filteredTimeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            filteredTimeLabelSubLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            filteredTimeLabelSubLabel.topAnchor.constraint(equalTo: filteredTimeLabel.bottomAnchor, constant: 8),
            filteredTimeLabelSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            allWorkloadButton.topAnchor.constraint(equalTo: filteredTimeLabelSubLabel.bottomAnchor, constant: 16),
            allWorkloadButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            allWorkloadButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            allWorkloadButton.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8)
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
