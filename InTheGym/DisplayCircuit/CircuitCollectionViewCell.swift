//
//  CircuitCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

import UIKit
import Combine

class CircuitCollectionViewCell: UICollectionViewCell {
    // MARK: - Publishers
    var actionPublisher = PassthroughSubject<CircuiCellAction,Never>()
    // MARK: - Properties
    static let reuseID: String = "CircuitCollectionViewCellreuseID"
    // MARK: - Subviews
    var exerciseNameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 30)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.1
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var topSepartorView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var setLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkColour
        button.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [exerciseNameButton, topSepartorView, setLabel, repLabel, weightLabel, completeButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initTargets()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        initTargets()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        actionPublisher = PassthroughSubject<CircuiCellAction,Never>()
    }
}
// MARK: - Configure
private extension CircuitCollectionViewCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        contentView.layer.cornerRadius = 8
        contentView.addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            exerciseNameButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            exerciseNameButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            
            topSepartorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            topSepartorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    func initTargets() {
        exerciseNameButton.addTarget(self, action: #selector(exerciseNameButtonAction(_:)), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonAction(_:)), for: .touchUpInside)
    }
}
// MARK: - Targets
private extension CircuitCollectionViewCell {
    @objc func exerciseNameButtonAction(_ sender: UIButton) {
        actionPublisher.send(.exerciseButton)
    }
    @objc func completeButtonAction(_ sender: UIButton) {
        actionPublisher.send(.completeButton)
    }
}
// MARK: - Public Config
extension CircuitCollectionViewCell {
    public func configure(with model: CircuitTableModel) {
        exerciseNameButton.setTitle(model.exerciseName, for: .normal)
        setLabel.text = "Set " + model.set.description
        repLabel.text = model.reps.description + " reps"
        weightLabel.text = model.weight
        completeButton.setImage(model.completed ? UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large)) : UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        completeButton.isUserInteractionEnabled = model.completed ? false : true
    }
}
