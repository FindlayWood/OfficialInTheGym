//
//  DisplaySetMoreInfoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplaySetMoreInfoView: UIView {
    // MARK: - Properties
    var initialFrame: CGRect!
    var flashview: FlashView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(remove))
            flashview.addGestureRecognizer(tap)
        }
    }
    
    // MARK: - Subviews
    var setLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 66)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.33
        label.textAlignment = .center
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
private extension DisplaySetMoreInfoView {
    func setupUI() {
        clipsToBounds = true
        backgroundColor = .darkColour
        layer.cornerRadius = 10
        layer.borderWidth = 4.0
        layer.borderColor = UIColor.black.cgColor
        addSubview(setLabel)
        labelStack.addArrangedSubview(repLabel)
        labelStack.addArrangedSubview(weightLabel)
        labelStack.addArrangedSubview(timeLabel)
        labelStack.addArrangedSubview(distanceLabel)
        labelStack.addArrangedSubview(restTimeLabel)
        addSubview(labelStack)
        viewStack.addArrangedSubview(timerView)
        viewStack.addArrangedSubview(calculatorView)
        //addSubview(viewStack)
        addSubview(completedButton)
        addSubview(closeButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([//setLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     //setLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

                                     labelStack.topAnchor.constraint(equalTo: setLabel.bottomAnchor, constant: 10),
                                     //labelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     //labelStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     labelStack.bottomAnchor.constraint(equalTo: completedButton.topAnchor, constant: -5),
                                     labelStack.centerXAnchor.constraint(equalTo: centerXAnchor),
                                        
                                     //viewStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     //viewStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     //viewStack.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 10),
        
                                     completedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     completedButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -5),
                                     closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
    }
}
// MARK: - Configure View
extension DisplaySetMoreInfoView {
    func configureView(with exercise: exercise, set: Int) {
        setLabel.text = "Set " + set.description
        repLabel.text = "\(exercise.repArray?[set - 1].description ?? "0") reps"
        weightLabel.text = exercise.weightArray?[set - 1]
        if let time = exercise.time?[set - 1] {
            timeLabel.text = "\(time) secs"
        }
        if let restTime = exercise.restTime?[set - 1] {
            restTimeLabel.text = "\(restTime) secs"
        }
        //timeLabel.text = "\(exercise.time?[set - 1].description ?? "0")secs"
        distanceLabel.text = exercise.distance?[set - 1]
    }
}

// MARK: - Actions
extension DisplaySetMoreInfoView {
    @objc func remove() {
        closeButton.isHidden = true
        timeLabel.isHidden = true
        distanceLabel.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
            self.flashview.alpha = 0
            self.frame = self.initialFrame
        } completion: { _ in
            self.flashview.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    func beginSubViewAnimation() {
        setLabel.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        repLabel.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        weightLabel.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        timeLabel.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        distanceLabel.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        completedButton.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        UIView.animate(withDuration: 0.3) {
            self.setLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.repLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.weightLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.timeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.distanceLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.completedButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    func removeAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.setLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.repLabel.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            self.weightLabel.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        }

    }
}
