//
//  WorkoutCreationView.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class WorkoutCreationView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "enter title..."
        field.textColor = .label
        field.font = .systemFont(ofSize: 22, weight: .bold)
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 8
        field.tintColor = .darkColour
        field.autocapitalizationType = .words
        field.backgroundColor = .secondarySystemBackground
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var optionsButton: UIButton = {
        let button = UIButton()
        button.setTitle("more Options", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var optionsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Options:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var middleSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Exercises:"
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exercisesTableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(ExerciseCreationTableViewCell.self, forCellReuseIdentifier: ExerciseCreationTableViewCell.cellID)
        view.register(CircuitCreationTableViewCell.self, forCellReuseIdentifier: CircuitCreationTableViewCell.cellID)
        view.register(AmrapCreationTableViewCell.self, forCellReuseIdentifier: AmrapCreationTableViewCell.cellID)
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var emptyMessage: UILabel = {
        let label = UILabel()
        label.text = "No Exercises.\n Tap the + icon below to add an exercise."
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
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
private extension WorkoutCreationView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(titleTextField)
        addSubview(topSeparatorView)
        addSubview(optionsButton)
        addSubview(middleSeparatorView)
        addSubview(exercisesLabel)
        addSubview(exercisesTableView)
        addSubview(plusButton)
        addSubview(emptyMessage)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            topSeparatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            optionsButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 8),
            optionsButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            middleSeparatorView.bottomAnchor.constraint(equalTo: optionsButton.topAnchor, constant: -8),
            middleSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            middleSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),

            exercisesLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 8),
            exercisesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            exercisesTableView.topAnchor.constraint(equalTo: exercisesLabel.bottomAnchor, constant: 8),
            exercisesTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            exercisesTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            exercisesTableView.bottomAnchor.constraint(equalTo: middleSeparatorView.topAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: exercisesTableView.trailingAnchor),
            plusButton.bottomAnchor.constraint(equalTo: exercisesTableView.bottomAnchor, constant: -8),
            
            emptyMessage.centerXAnchor.constraint(equalTo: exercisesTableView.centerXAnchor),
            emptyMessage.centerYAnchor.constraint(equalTo: exercisesTableView.centerYAnchor),
            emptyMessage.widthAnchor.constraint(equalTo: exercisesTableView.widthAnchor, constant: -20)
        ])
    }
}
// MARK: - Public Configuration
extension WorkoutCreationView {
    public func reset() {
        titleTextField.text = ""
    }
}
