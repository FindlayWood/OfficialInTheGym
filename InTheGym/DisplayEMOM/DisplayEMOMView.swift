//
//  DisplayEMOMView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayEMOMView: UIView {
    
    // MARK: - Subviews
    var fullTimePrgoressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var minuteProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var exerciseView: EMOMExerciseView = {
        let view = EMOMExerciseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var initialMainTime: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.textColor = .lightColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var initialMinuteTime: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.textColor = .lightColour
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
}

// MARK: - Setup UI
private extension DisplayEMOMView {
    func setupUI() {
        backgroundColor = .white
        addSubview(fullTimePrgoressView)
        addSubview(minuteProgressView)
        addSubview(exerciseView)
        addSubview(initialMainTime)
        addSubview(initialMinuteTime)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            fullTimePrgoressView.topAnchor.constraint(equalTo: topAnchor),
            fullTimePrgoressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            fullTimePrgoressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            fullTimePrgoressView.heightAnchor.constraint(equalTo: fullTimePrgoressView.widthAnchor),
            
            minuteProgressView.topAnchor.constraint(equalTo: fullTimePrgoressView.bottomAnchor, constant: 10),
            minuteProgressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            minuteProgressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            minuteProgressView.heightAnchor.constraint(equalTo: minuteProgressView.widthAnchor),
            
            exerciseView.topAnchor.constraint(equalTo: minuteProgressView.bottomAnchor, constant: 20),
            exerciseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            exerciseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            initialMainTime.centerXAnchor.constraint(equalTo: fullTimePrgoressView.centerXAnchor),
            initialMainTime.centerYAnchor.constraint(equalTo: fullTimePrgoressView.centerYAnchor),
            
            initialMinuteTime.centerXAnchor.constraint(equalTo: minuteProgressView.centerXAnchor),
            initialMinuteTime.centerYAnchor.constraint(equalTo: minuteProgressView.centerYAnchor)
            
        ])
    }
}

// MARK: - Actions
extension DisplayEMOMView {
    public func updateFullTime() {
        fullTimePrgoressView.timeRemaining = 100
        fullTimePrgoressView.progress = 0.7
    }
}
