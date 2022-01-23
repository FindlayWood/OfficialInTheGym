//
//  DisplayAMRAPView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayAMRAPView: UIView {
    
    // MARK: - Properties
    private let collectionHeight = Constants.screenSize.height * 0.4
    
    // MARK: - Subviews
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 80)
        label.textColor = Constants.offWhiteColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var initialTimeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var timeProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var helpIcon: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "help-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var amrapExerciseView: AMRAPExerciseView = {
        let view = AMRAPExerciseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var roundsView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.offWhiteColour
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var roundsNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 40)
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    var roundsLabel: UILabel = {
        let label = UILabel()
        label.text = "Rounds"
        label.font = Constants.font
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    var exerciseView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.offWhiteColour
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var exerciseNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 40)
        label.textColor = Constants.darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.text = "Exercises"
        label.font = Constants.font
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Setup UI
private extension DisplayAMRAPView {
    func setup() {
        //addSubview(timeLabel)
        addSubview(timeProgressView)
        addSubview(initialTimeLabel)
        
        addSubview(helpIcon)
        addSubview(amrapExerciseView)
        addSubview(roundsView)
        
        roundsView.addSubview(roundsNumberLabel)
        roundsView.addSubview(roundsLabel)
        
        addSubview(exerciseView)
        //addSubview(timeProgressView)
        exerciseView.addSubview(exerciseNumberLabel)
        exerciseView.addSubview(exerciseLabel)
        constrain()
    }
    
    func constrain() {
        NSLayoutConstraint.activate([
                                     
            
                                     timeProgressView.topAnchor.constraint(equalTo: topAnchor),
                                     timeProgressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
                                     timeProgressView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     timeProgressView.heightAnchor.constraint(equalTo: timeProgressView.widthAnchor),
                                     
                                     initialTimeLabel.centerXAnchor.constraint(equalTo: timeProgressView.centerXAnchor),
                                     initialTimeLabel.centerYAnchor.constraint(equalTo: timeProgressView.centerYAnchor),
                                     
                                     helpIcon.centerYAnchor.constraint(equalTo: timeProgressView.centerYAnchor),
                                     helpIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     helpIcon.heightAnchor.constraint(equalToConstant: 50),
                                     helpIcon.widthAnchor.constraint(equalToConstant: 50),
                                     
                                     
                                     roundsView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -20),
                                     roundsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                                     //roundsView.topAnchor.constraint(equalTo: amrapExerciseView.bottomAnchor, constant: 10),
                                     roundsView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15),
                                     roundsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     
                                     roundsNumberLabel.centerXAnchor.constraint(equalTo: roundsView.centerXAnchor),
                                     roundsNumberLabel.centerYAnchor.constraint(equalTo: roundsView.centerYAnchor, constant: -20),
                                     
                                     roundsLabel.bottomAnchor.constraint(equalTo: roundsView.bottomAnchor, constant: -5),
                                     roundsLabel.leadingAnchor.constraint(equalTo: roundsView.leadingAnchor),
                                     roundsLabel.trailingAnchor.constraint(equalTo: roundsView.trailingAnchor),
                                     
                                     exerciseView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 20),
                                     exerciseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                                     //exerciseView.topAnchor.constraint(equalTo: amrapExerciseView.bottomAnchor, constant: 10),
                                     exerciseView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15),
                                     exerciseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     
                                     exerciseNumberLabel.centerXAnchor.constraint(equalTo: exerciseView.centerXAnchor),
                                     exerciseNumberLabel.centerYAnchor.constraint(equalTo: exerciseView.centerYAnchor, constant: -20),
                                     
                                     exerciseLabel.bottomAnchor.constraint(equalTo: exerciseView.bottomAnchor, constant: -5),
                                     exerciseLabel.leadingAnchor.constraint(equalTo: exerciseView.leadingAnchor),
                                     exerciseLabel.trailingAnchor.constraint(equalTo: exerciseView.trailingAnchor),
                                     
                                     amrapExerciseView.topAnchor.constraint(equalTo: timeProgressView.bottomAnchor, constant: 10),
                                     amrapExerciseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     amrapExerciseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     amrapExerciseView.bottomAnchor.constraint(equalTo: roundsView.topAnchor, constant: -10)
        ])
    }
}
