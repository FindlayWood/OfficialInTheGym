//
//  JumpResultsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class JumpResultsView: UIView {
    // MARK: - Subviews
    var segment: CustomisedSegmentControl = {
        let view = CustomisedSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width - 32, height: 40), buttonTitles: ["cm", "inches"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var resultMeasurementLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [resultLabel,resultMeasurementLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save Jump", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [segment,hstack,saveButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
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
// MARK: - Configure
private extension JumpResultsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            
            segment.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),
            segment.heightAnchor.constraint(equalToConstant: 40),
            
            resultLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
        ])
    }
}
// MARK: - Public Config
extension JumpResultsView {
    func configure(with result: Double, _ cm: Bool) {
        resultLabel.text = result.description
        resultMeasurementLabel.text = cm ? "cm" : "in"
    }
}
