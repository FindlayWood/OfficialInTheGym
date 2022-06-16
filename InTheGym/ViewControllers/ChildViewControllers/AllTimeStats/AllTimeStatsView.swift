//
//  AllTimeStatsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AllTimeStatsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
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
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [allTimeLabel,totalWorkoutsLabel,totalWorkoutsSubLabel,totalTimeLabel,totalTimeSubLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
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
private extension AllTimeStatsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            totalWorkoutsLabel.heightAnchor.constraint(equalTo: totalTimeLabel.heightAnchor),
            
            allTimeLabel.heightAnchor.constraint(equalToConstant: 30),
            totalTimeSubLabel.heightAnchor.constraint(equalToConstant: 30),
            totalWorkoutsSubLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
// MARK: - Public Config
extension AllTimeStatsView {
    public func configure(with model: MyWorkoutStatsModel) {
        totalWorkoutsLabel.text = model.totalWorkoutsComplete.description
        totalTimeLabel.text = model.totalWorkoutTime.convertToWorkoutTime()
    }
}
