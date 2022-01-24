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
    
    var completedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .right
        label.text = "COMPLETED"
        label.textColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var roundsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    override func prepareForReuse() {
        super.prepareForReuse()
        //amrapModel.completed.valueChanged = nil
        //amrapModel.roundsCompleted.valueChanged = nil
        completedLabel.isHidden = true
        roundsLabel.isHidden = true
    }
}
// MARK: - Setup UI
private extension MainWorkoutAMRAPCollectionCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        addSubview(amrapLabel)
        addSubview(separatorView)
        addSubview(exerciseLabel)
        addSubview(timeLabel)
//        addSubview(completedLabel)
        addSubview(roundsLabel)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([
            amrapLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            amrapLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            separatorView.topAnchor.constraint(equalTo: amrapLabel.bottomAnchor, constant: 5),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -10),
            
            exerciseLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 10),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
//            completedLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            completedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            roundsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            roundsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}

// MARK: - Public Configuration
extension MainWorkoutAMRAPCollectionCell {
    
    func configure(with model: AMRAPModel) {
        exerciseLabel.text = model.exercises.count.description + " exercises"
        timeLabel.text = model.timeLimit.convertToTime()
    }
}
