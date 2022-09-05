//
//  MainWorkoutEMOMCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

/// this class creates the cell to be displayed for an EMOM
class MainWorkoutEMOMCollectionCell: FullWidthCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "MainWorkoutEMOMCollectionCell"
    // MARK: - Subviews
    var emomLabel: UILabel = {
        let label = UILabel()
        label.text = "EMOM"
        label.font = Constants.font
        label.textColor = .black
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
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emomLabel,separatorView,exerciseLabel,timeLabel,completedIcon])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
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
// MARK: - Setup UI
private extension MainWorkoutEMOMCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
//        layer.masksToBounds = true
//        addSubview(emomLabel)
//        addSubview(separatorView)
//        addSubview(exerciseLabel)
//        addSubview(timeLabel)
//        addSubview(completedIcon)
        addSubview(stack)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
//            emomLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//            emomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
//            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            separatorView.topAnchor.constraint(equalTo: emomLabel.bottomAnchor, constant: 8),
            
//            exerciseLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
//            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
//            timeLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 8),
//            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
//            completedIcon.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
//            completedIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//            completedIcon.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension MainWorkoutEMOMCollectionCell {
    public func configure(with model: EMOMModel) {
        timeLabel.text = model.timeLimit.convertToTime()
        exerciseLabel.text = model.exercises.count.description + " exercises"
        completedIcon.image = model.completed ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
    }
}
