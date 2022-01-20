//
//  SavedWorkoutOptionsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SavedWorkoutOptionsView: UIView {
    
    // MARK: - Publishers
    var actionPublisher = PassthroughSubject<OptionsAction,Never>()
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 29)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 10
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 10
        button.setTitle("Add To Workouts", for: .normal)
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var statsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 10
        button.setTitle("Workout Stats", for: .normal)
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [saveButton,addButton,statsButton])
        view.axis = .vertical
        view.spacing = 10
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
// MARK: - Configure
private extension SavedWorkoutOptionsView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(tableview)
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            tableview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.heightAnchor.constraint(equalToConstant: 80),
            
            stack.topAnchor.constraint(equalTo: tableview.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}

