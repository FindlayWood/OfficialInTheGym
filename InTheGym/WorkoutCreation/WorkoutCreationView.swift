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
    var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Title:"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workoutTitleField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.tintColor = .white
        field.returnKeyType = .done
        field.textColor = .white
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 2
        field.titleColor = .white
        field.lineColor = .white
        field.title = ""
        field.selectedTitle = ""
        field.selectedTitleColor = .white
        field.selectedLineColor = .white
        field.placeholder = "enter workout title..."
        field.font = .systemFont(ofSize: 20, weight: .bold)
        field.clearButtonMode = .never
        field.autocapitalizationType = .words
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    var privacyView: PrivacyView = {
        let view = PrivacyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var saveView: UISaveView = {
        let view = UISaveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var assignView: AssignView = {
        let view = AssignView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var middleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [assignView, privacyView, saveView])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exercisesView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Exercises:"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exercisesTableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.layer.cornerRadius = 8
        view.register(ExerciseCreationTableViewCell.self, forCellReuseIdentifier: ExerciseCreationTableViewCell.cellID)
        view.register(CircuitCreationTableViewCell.self, forCellReuseIdentifier: CircuitCreationTableViewCell.cellID)
        view.register(EmomCreationTableViewCell.self, forCellReuseIdentifier: EmomCreationTableViewCell.cellID)
        view.register(AmrapCreationTableViewCell.self, forCellReuseIdentifier: AmrapCreationTableViewCell.cellID)
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bluePlus3"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var emptyMessage: UILabel = {
        let label = UILabel()
        label.text = "No Exercises.\n Tap the + icon below to add an exercise."
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .lightGray
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
        backgroundColor = .white
        titleView.addSubview(workoutTitleField)
        titleView.addSubview(titleLabel)
        exercisesView.addSubview(exercisesLabel)
        exercisesView.addSubview(exercisesTableView)
        exercisesView.addSubview(plusButton)
        addSubview(titleView)
        addSubview(middleStack)
        addSubview(exercisesView)
        addSubview(emptyMessage)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            
            workoutTitleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -4),
            workoutTitleField.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            workoutTitleField.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -8),
            workoutTitleField.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -20),
            
            middleStack.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            middleStack.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            middleStack.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            
            saveView.heightAnchor.constraint(equalTo: privacyView.heightAnchor),
            
            exercisesView.topAnchor.constraint(equalTo: middleStack.bottomAnchor, constant: 8),
            exercisesView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            exercisesView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            exercisesView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            exercisesLabel.topAnchor.constraint(equalTo: exercisesView.topAnchor, constant: 10),
            exercisesLabel.leadingAnchor.constraint(equalTo: exercisesView.leadingAnchor, constant: 10),
            exercisesTableView.topAnchor.constraint(equalTo: exercisesLabel.bottomAnchor, constant: 8),
            exercisesTableView.leadingAnchor.constraint(equalTo: exercisesView.leadingAnchor, constant: 10),
            exercisesTableView.trailingAnchor.constraint(equalTo: exercisesView.trailingAnchor, constant: -10),
            exercisesTableView.bottomAnchor.constraint(equalTo: exercisesView.bottomAnchor, constant: -10),
            
            plusButton.trailingAnchor.constraint(equalTo: exercisesTableView.trailingAnchor, constant: -5),
            plusButton.bottomAnchor.constraint(equalTo: exercisesTableView.bottomAnchor, constant: -5),
            
            emptyMessage.centerXAnchor.constraint(equalTo: exercisesTableView.centerXAnchor),
            emptyMessage.centerYAnchor.constraint(equalTo: exercisesTableView.centerYAnchor),
            emptyMessage.widthAnchor.constraint(equalTo: exercisesTableView.widthAnchor, constant: -20)
        ])
    }
}

// MARK: - Public Configuration
extension WorkoutCreationView {
    public func configure(with user: Users?) {
        if let user = user {
            assignView.configure(with: user)
        } else {
            assignView.isHidden = true
        }
    }
}
