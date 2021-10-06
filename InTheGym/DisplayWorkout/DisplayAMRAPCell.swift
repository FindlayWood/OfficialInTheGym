//
//  DisplayAMRAPCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayAMRAPCell: UITableViewCell, workoutCellConfigurable {
    
    // MARK: - Properties
    var delegate: DisplayWorkoutProtocol!
    var amrapModel: AMRAP!
    static let cellID = "DisplayAMRAPCellID"
    
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        backgroundColor = Constants.offWhiteColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        selectionStyle = .none
        addSubview(amrapLabel)
        addSubview(separatorView)
        addSubview(exerciseLabel)
        addSubview(timeLabel)
        addSubview(completedLabel)
        addSubview(roundsLabel)
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([amrapLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
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
        
                                     completedLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     completedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        
                                     roundsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
                                     roundsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)])
    }
    
    func setup(with rowModel: WorkoutType) {
        amrapModel = rowModel as? AMRAP
        exerciseLabel.text = (amrapModel.exercises?.count.description ?? "0") + " Exercises"
        timeLabel.text = (amrapModel.timeLimit?.description ?? "10") + " minutes"
        if let completed = amrapModel.completed.value {
            completedLabel.isHidden = !completed
        }
        if let rounds = amrapModel.roundsCompleted.value {
            if rounds > 0 {
                roundsLabel.text = rounds.description
                roundsLabel.isHidden = false
            } else {
                roundsLabel.isHidden = true
            }
        }
        
        amrapModel.completed.valueChanged = { [weak self] newValue in
            guard let self = self else {return}
            if newValue {
                self.completedLabel.isHidden = false
            } else {
                self.completedLabel.isHidden = true
            }
        }
        amrapModel.roundsCompleted.valueChanged = { [weak self] newValue in
            guard let self = self else {return}
            if newValue > 0 {
                self.roundsLabel.text = newValue.description
                self.roundsLabel.isHidden = false
            } else {
                self.roundsLabel.isHidden = true
            }
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        amrapModel.completed.valueChanged = nil
        amrapModel.roundsCompleted.valueChanged = nil
        completedLabel.isHidden = true
        roundsLabel.isHidden = true

    }
}
