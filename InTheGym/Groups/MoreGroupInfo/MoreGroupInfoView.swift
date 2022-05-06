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
    
    var groupImageButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.imageView?.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var nameTextField: UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.font = .systemFont(ofSize: 25, weight: .bold)
        field.returnKeyType = .done
        field.autocapitalizationType = .words
        field.isUserInteractionEnabled = true
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 10
        field.tintColor = .darkColour
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var descriptionTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = true
        view.isScrollEnabled = false
        view.autocapitalizationType = .sentences
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.layer.cornerRadius = 8
        view.textColor = .secondaryLabel
        view.addToolBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        backgroundColor = .secondarySystemBackground
        addSubview(cancelButton)
        addSubview(saveButton)
        addSubview(groupImageButton)
        addSubview(nameTextField)
        addSubview(descriptionTextView)
        addSubview(characterCountLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            saveButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            groupImageButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 16),
            groupImageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            groupImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            groupImageButton.heightAnchor.constraint(equalToConstant: 150),
            
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameTextField.topAnchor.constraint(equalTo: groupImageButton.bottomAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 48),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 80),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            characterCountLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4)
        ])
    }
}

// MARK: - Configure View
extension MoreGroupInfoView {
    public func configure(with info: GroupModel) {
        nameTextField.text = info.username
        descriptionTextView.text = info.description
        setCharacterCount(info.description.count)
        
        let imageDownloadModel = ProfileImageDownloadModel(id: info.uid)
        ImageCache.shared.load(from: imageDownloadModel) { [weak self] result in
            guard let image = try? result.get() else {
                self?.groupImageButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self?.groupImageButton.tintColor = .darkColour
                return
            }
            self?.groupImageButton.setImage(image, for: .normal)
        }
    }
    public func setCharacterCount(_ count: Int) {
        guard count <= 200 else {return}
        characterCountLabel.text = (200 - count).description
    }
    public func setLoading(_ loading: Bool) {
        if loading {
            cancelButton.isUserInteractionEnabled = false
            saveButton.isUserInteractionEnabled = false
            groupImageButton.isUserInteractionEnabled = false
            nameTextField.isUserInteractionEnabled = false
            descriptionTextView.isUserInteractionEnabled = false
        } else {
            cancelButton.isUserInteractionEnabled = true
            saveButton.isUserInteractionEnabled = true
            groupImageButton.isUserInteractionEnabled = true
            nameTextField.isUserInteractionEnabled = true
            descriptionTextView.isUserInteractionEnabled = true
        }
    }
}




