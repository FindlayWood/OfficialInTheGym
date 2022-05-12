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
        label.font = UIFont(name: "Menlo-Bold", size: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Set 1"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var restTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.2
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(remove), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 5
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
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkColour
        view.layer.cornerRadius = 8
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
        addSubview(setLabel)
        addSubview(dismissButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backgroundView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            setLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            setLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            dismissButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8)
        ])
    }
}
// MARK: - Configure View
extension DisplaySingleSetView {
    func configureView(with exercise: ExerciseModel, set: Int) {

    }
}

// MARK: - Actions
extension DisplaySingleSetView {
    @objc func remove() {
        closeButton.isHidden = true
        timeLabel.isHidden = true
        distanceLabel.isHidden = true
    }
    func beginSubViewAnimation() {
    }
    func removeAnimation() {

    }
}
