//
//  WorkoutBottomChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutBottomChildView: UIView {
    
    // MARK: - Properties
    let firstStageMessage = "Scroll to view exercises. When ready tap Begin Workout to start the workout."
    let secondStageMessage = "Are you ready? Tap Continue to start the timer and begin the workout."
    
    // MARK: - Subviews
    var newButton: UIButton = {
        let button = UIButton()
        button.setTitle("Begin Workout", for: .normal)
        button.backgroundColor = .darkColour
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.05).isActive = true
        button.layer.cornerRadius = 8
        button.addViewShadow(with: .darkColour)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = firstStageMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [newButton, label, cancelButton])
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var centerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
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
// MARK: - Configure
private extension WorkoutBottomChildView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.maskedCorners = [ .layerMinXMinYCorner, . layerMaxXMinYCorner]
        addViewTopShadow(with: .black)
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        
        addFullConstraint(to: stack, withConstant: 8)
    }
}

// MARK: - Public
extension WorkoutBottomChildView {
    public func changeStage(to stage: WorkoutBottomViewStage) {
        switch stage {
        case .first:
            newButton.setTitle("Begin Workout", for: .normal)
            label.text = firstStageMessage
            cancelButton.isHidden = true
        case .second:
            newButton.setTitle("Continue", for: .normal)
            label.text = secondStageMessage
            cancelButton.isHidden = false
        case .third(let title):
            stack.removeFromSuperview()
            addSubview(centerLabel)
            centerLabel.text = title
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
}
