//
//  WorkoutDiscoveryView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

import UIKit

class WorkoutDiscoveryView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var segment: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 40), buttonTitles: ["Comments", "Tags"])
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var containerView: UIView = {
        let view = UIView()
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
// MARK: - Configure
private extension WorkoutDiscoveryView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(workoutView)
        addSubview(segment)
        addSubview(containerView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            workoutView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            workoutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            workoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            segment.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: 8),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor),
            segment.heightAnchor.constraint(equalToConstant: 40),
            
            containerView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
