//
//  DescriptionUploadView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class DescriptionUploadView: UIView {
    
    // MARK: - Properties
    let placeholder = "write something here.."
    
    // MARK: - Subviews
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .darkColour
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .darkColour
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var profileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "note_icon")
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var descriptionTextView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        view.textColor = .secondaryLabel
        view.backgroundColor = .secondarySystemBackground
        view.tintColor = .darkColour
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .darkColour
        view.hidesWhenStopped = true
        view.isHidden = true
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
private extension DescriptionUploadView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(cancelButton)
        addSubview(uploadButton)
        addSubview(iconImageView)
        addSubview(profileImage)
        addSubview(descriptionTextView)
        addSubview(characterCountLabel)
        addSubview(loadingIndicator)
        configureUI()
        setProfileImage()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            uploadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            uploadButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            iconImageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            profileImage.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: profileImage.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            characterCountLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 30),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setProfileImage() {
        let imageSearchModel = ProfileImageDownloadModel(id: UserDefaults.currentUser.uid)
        ImageCache.shared.load(from: imageSearchModel) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.profileImage.image = image
        }
    }
}

// MARK: - Public Configuration
extension DescriptionUploadView {
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            uploadButton.isHidden = true
            cancelButton.isHidden = true
            descriptionTextView.isUserInteractionEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            uploadButton.isHidden = false
            cancelButton.isHidden = false
            descriptionTextView.isUserInteractionEnabled = true
        }
    }
    public func setCharacterCount(_ count: Int) {
        guard count <= 500 else {return}
        characterCountLabel.text = (500 - count).description
    }
}
