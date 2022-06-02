//
//  MainWorkoutAMRAPCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainWorkoutAMRAPCollectionCell: FullWidthCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "MainWorkoutAMRAPCollectionCellreuseID"
    // MARK: - Subviews
    var amrapLabel: UILabel = {
       let label = UILabel()
        label.text = "AMRAP"
        label.font = Constants.font
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    var timeLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 20)
        label.textColor = .black
        label.textAlignment = .center
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
// MARK: - Setup UI
private extension MainWorkoutAMRAPCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        addSubview(amrapLabel)
        addSubview(separatorView)
        addSubview(exerciseLabel)
        addSubview(timeLabel)
        addSubview(completedIcon)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            amrapLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            amrapLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            separatorView.topAnchor.constraint(equalTo: amrapLabel.bottomAnchor, constant: 8),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
            
            exerciseLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 8),
            
            completedIcon.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            completedIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            completedIcon.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension MainWorkoutAMRAPCollectionCell {
    public func configure(with model: AMRAPModel) {
        exerciseLabel.text = model.exercises.count.description + " exercises"
        timeLabel.text = model.timeLimit.convertToTime()
        completedIcon.image = model.completed ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
    }
}
