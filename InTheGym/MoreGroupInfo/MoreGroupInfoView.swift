//
//  MoreGroupInfoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MoreGroupInfoView: UIView {
    
    // MARK: - Subviews
    /// subviews contain an imageview, tableview view, save button and dismiss button
    
    var cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitle("dismiss", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var saveButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle("Save", for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var groupImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var editPhotoButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle("edit photo", for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Group Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var nameTextField: UITextField = {
        let field = UITextField()
        field.textColor = .darkColour
        field.font = Constants.font
        field.returnKeyType = .done
        field.autocapitalizationType = .words
        field.isUserInteractionEnabled = false
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var editNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Group Description"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var descriptionTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.isScrollEnabled = false
        view.autocapitalizationType = .sentences
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var editDescriptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.cellID)
        view.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
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
private extension MoreGroupInfoView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        addSubview(cancelButton)
        addSubview(saveButton)
        
        addSubview(groupImageView)
        addSubview(editPhotoButton)
        
        addSubview(nameLabel)
        addSubview(nameTextField)
        addSubview(editNameButton)
        
        addSubview(descriptionLabel)
        addSubview(descriptionTextView)
        addSubview(editDescriptionButton)
        
        addSubview(tableview)
        constrainUI()
        
        let bar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endDescriptionEditing))
        bar.items = [flexibleSpace, done]
        bar.sizeToFit()
        descriptionTextView.inputAccessoryView = bar
        
        editNameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        editDescriptionButton.addTarget(self, action: #selector(editDescription), for: .touchUpInside)
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            
            saveButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            groupImageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10),
            groupImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            groupImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            groupImageView.heightAnchor.constraint(equalToConstant: 150),
            
            editPhotoButton.centerXAnchor.constraint(equalTo: groupImageView.centerXAnchor),
            editPhotoButton.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 5),
            
            nameLabel.topAnchor.constraint(equalTo: editPhotoButton.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            nameTextField.heightAnchor.constraint(equalToConstant: 45),
            editNameButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editNameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 80),
            editDescriptionButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            editDescriptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            tableview.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        ])
    }
}

// MARK: - Configure View
extension MoreGroupInfoView {
    public func configure(with info: MoreGroupInfoModel) {
        nameTextField.text = info.groupName
        descriptionTextView.text = info.description
        groupImageView.image = info.headerImage
    }
}

// MARK: - Actions
extension MoreGroupInfoView {
    @objc func editName() {
        nameTextField.isUserInteractionEnabled = true
        nameTextField.becomeFirstResponder()
        editNameButton.isEnabled = false
    }
    @objc func editDescription() {
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.becomeFirstResponder()
        editDescriptionButton.isEnabled = false
    }
    @objc func endDescriptionEditing() {
        descriptionTextView.isUserInteractionEnabled = false
        editDescriptionButton.isEnabled = true
    }
}




