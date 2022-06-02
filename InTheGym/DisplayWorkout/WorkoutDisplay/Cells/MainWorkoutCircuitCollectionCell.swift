//
//  MainWorkoutCircuitCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainWorkoutCircuitCollectionCell: FullWidthCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "MainWorkoutCircuitCollectionCell"
    // MARK: - Subviews
    var circuitLabel: UILabel = {
        let label = UILabel()
        label.text = "Circuit"
        label.font = UIFont(name: "Menlo", size: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 15)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var completedIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "circle")
        view.tintColor = .darkColour
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
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
private extension MainWorkoutCircuitCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        addSubview(circuitLabel)
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(exercisesLabel)
        addSubview(completedIcon)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            circuitLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            circuitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            circuitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: circuitLabel.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            titleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            exercisesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            exercisesLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            completedIcon.topAnchor.constraint(equalTo: exercisesLabel.bottomAnchor, constant: 8),
            completedIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            completedIcon.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension MainWorkoutCircuitCollectionCell {
    public func configure(with model: CircuitModel) {
        titleLabel.text = model.circuitName
        exercisesLabel.text = model.exercises.count.description + " exercises"
        completedIcon.image = model.completed ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
    }
}
