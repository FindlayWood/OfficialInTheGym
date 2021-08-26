//
//  UploadGroupWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadGroupWorkoutView: UIView {
    // MARK: - Subviews
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.text = "Uploading To"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var assigneeView: UIAssignableView = {
        let view = UIAssignableView()
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

private extension UploadGroupWorkoutView {
    func setupUI() {
        
        backgroundColor = .white
        addSubview(workoutView)
        addSubview(label)
        addSubview(assigneeView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            workoutView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            workoutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            workoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: 10),
            
            assigneeView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            assigneeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            assigneeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}

extension UploadGroupWorkoutView {
    func configureWorkoutView(with data: UploadableWorkout) {
        workoutView.configure(with: data.workout)
        assigneeView.configure(with: data.assignee)
    }
}
