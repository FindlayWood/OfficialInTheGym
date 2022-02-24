//
//  ProgramCreationDetailView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ProgramCreationDetailView: UIView {
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
    
    var descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Description:"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var descriptionTextView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.backgroundColor = .white
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .darkGray
        view.tintColor = .lightColour
        view.layer.cornerRadius = 8
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
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
private extension ProgramCreationDetailView {
    func setupUI() {
        backgroundColor = .white
        titleView.addSubview(workoutTitleField)
        titleView.addSubview(titleLabel)
        addSubview(titleView)
        descriptionView.addSubview(descriptionLabel)
        descriptionView.addSubview(descriptionTextView)
        addSubview(descriptionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            
            workoutTitleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -4),
            workoutTitleField.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            workoutTitleField.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -8),
            workoutTitleField.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -20),
            
            descriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16),
            descriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 8),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 8),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -8),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -8)
        ])
    }
}

extension ProgramCreationDetailView {
    public func setInteraction(to allowed: Bool) {
        workoutTitleField.isUserInteractionEnabled = allowed
        descriptionTextView.isUserInteractionEnabled = allowed
    }
    public func clearFields() {
        workoutTitleField.text = ""
        descriptionTextView.text = ""
    }
}

