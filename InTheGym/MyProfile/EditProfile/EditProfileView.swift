//
//  EditProfileView.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class EditProfileView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkColour
        button.backgroundColor = .lightGray
//        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var profileBioTextView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .secondaryLabel
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 8
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
    var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension EditProfileView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(profileImageButton)
        addSubview(characterCountLabel)
        addSubview(profileBioTextView)
        addSubview(doneButton)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 100),
            profileImageButton.heightAnchor.constraint(equalToConstant: 100),
            
            profileBioTextView.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 16),
            profileBioTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileBioTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: profileBioTextView.trailingAnchor),
            characterCountLabel.topAnchor.constraint(equalTo: profileBioTextView.bottomAnchor, constant: 4),
            
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
// MARK: - Public Configuration
extension EditProfileView {
    public func setCharacterCount(_ count: Int) {
        guard count <= 200 else {return}
        characterCountLabel.text = (200 - count).description
    }
}
