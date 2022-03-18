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
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Upload", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.isEnabled = false
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
    
    lazy var descriptionTextView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 17, weight: .medium)
        view.textColor = .lightGray
        view.text = placeholder
        view.backgroundColor = .clear
        view.tintColor = .darkColour
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .darkColour
        view.hidesWhenStopped = true
        view.isHidden = true
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
private extension DescriptionUploadView {
    func setupUI() {
        backgroundColor = .white
        addSubview(cancelButton)
        addSubview(uploadButton)
        addSubview(profileImage)
        addSubview(descriptionTextView)
        addSubview(separatorView)
        addSubview(messageLabel)
        addSubview(loadingIndicator)
        configureUI()
        setProfileImage()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            uploadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            uploadButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            profileImage.topAnchor.constraint(equalTo: uploadButton.bottomAnchor, constant: 8),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: profileImage.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            separatorView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
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
}
