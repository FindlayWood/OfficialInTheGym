//
//  DisplaySetMoreInfoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplaySingleSetView: UIView {
    
    // MARK: - Properties

    
    // MARK: - Subviews
    var setLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Set 1"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 30)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "clock_icon")
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.widthAnchor.constraint(equalToConstant: 48).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 30)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var distanceIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "distance_icon")
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.widthAnchor.constraint(equalToConstant: 48).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var restTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 30)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var restTimeIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "restTime_icon")
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.widthAnchor.constraint(equalToConstant: 48).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var timerView: UIImageLabelView = {
        var view = UIImageLabelView()
        view.configureView(image: UIImage(named: "clock_icon")!, label: "Timer")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var calculatorView: UIImageLabelView = {
        var view = UIImageLabelView()
        view.configureView(image: UIImage(named: "calculator_icon")!, label: "Calculator")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var completedButton: UIButton = {
        let button = UIButton()
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.setImage(UIImage(named: "tickRing"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [setLabel,repLabel,weightLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var moreInfoLabelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeVStack,distanceVStack,restTimeVStack])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var viewStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var setView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkColour
        view.layer.cornerRadius = 8
        view.addViewShadow(with: .black)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(named: "emptyRing"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var timeVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeIcon,timeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.isHidden = true
        return stack
    }()
    lazy var distanceVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [distanceIcon,distanceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.isHidden = true
        return stack
    }()
    lazy var restTimeVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [restTimeIcon,restTimeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.isHidden = true
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
// MARK: - Setup UI
private extension DisplaySingleSetView {
    func setupUI() {
        backgroundColor = .clear
        addSubview(backgroundView)
        addSubview(setView)
        addSubview(labelStack)
        addSubview(moreInfoLabelStack)
        addSubview(completeButton)
        addSubview(dismissButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 1.171),
            
            setView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            setView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            setView.widthAnchor.constraint(equalToConstant: 128),
            setView.heightAnchor.constraint(equalToConstant: 150),
            
            labelStack.topAnchor.constraint(equalTo: setView.topAnchor, constant: 10),
            labelStack.centerXAnchor.constraint(equalTo: setView.centerXAnchor),
            
            completeButton.bottomAnchor.constraint(equalTo: setView.bottomAnchor),
            completeButton.centerXAnchor.constraint(equalTo: setView.centerXAnchor),
            
            moreInfoLabelStack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16),
            moreInfoLabelStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            moreInfoLabelStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            moreInfoLabelStack.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            timeLabel.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.8),
            distanceLabel.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.8),
            restTimeLabel.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.8),

            dismissButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8)
        ])
    }
}
// MARK: - Configure View
extension DisplaySingleSetView {
    func configure(with exercise: ExerciseSet) {
        backgroundView.backgroundColor = exercise.completed ? .darkColour : .lightColour
        completeButton.setImage(exercise.completed ? UIImage(named: "tickRing") : UIImage(named: "emptyRing"), for: .normal)
        completeButton.isUserInteractionEnabled = exercise.completed ? false : false
        setLabel.text = "Set \(exercise.set)"
        repLabel.text = "\(exercise.reps) reps"
        weightLabel.text = exercise.weight
        if let time = exercise.time {
            if time > 0 {
                timeVStack.isHidden = false
                timeLabel.text = "\(time)s"
            }
        }
        if let distance = exercise.distance {
            if !(distance.trimTrailingWhiteSpaces().isEmpty) {
                distanceVStack.isHidden = false
                distanceLabel.text = distance
            }
        }
        if let restTime = exercise.restTime {
            if restTime > 0 {
                restTimeVStack.isHidden = false
                restTimeLabel.text = "\(restTime)s"
            }
        }
    }
}
