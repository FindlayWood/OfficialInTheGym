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
            
            exerciseView.topAnchor.constraint(equalTo: centerYAnchor),
            exerciseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            exerciseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
            
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
