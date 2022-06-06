//
//  CreateNewPostView.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateNewPostView: UIView {
    
    // MARK: - Properties
    let placeholder = "write something here.."
    
    let cameraImage: UIImage = UIImage(named: "camera_icon")!
    let clipImage: UIImage = UIImage(named: "clip_icon")!
    let workoutImage: UIImage = UIImage(named: "benchpress_icon")!
    
    private var privateImage = UIImage(named:"locked_icon")
    private var publicImage = UIImage(named: "public_icon")
    
    // MARK: - Subviews
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var postButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("POST", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        // MARK: - Text & Attachment Stack
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
    
    lazy var messageText: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 17, weight: .medium)
        view.textColor = .lightGray
        view.text = placeholder
        view.backgroundColor = .clear
        view.tintColor = .white
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var attachmentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var removeAttachmentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        //end of text stack views
    var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var newView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
        // MARK: - StackViews
    lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setImage(cameraImage, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    lazy var clipButton: UIButton = {
        let button = UIButton()
        button.setImage(clipImage, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    lazy var workoutButton: UIButton = {
        let button = UIButton()
        button.setImage(workoutImage, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        // end of stack views
    
    var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 40
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setImage(publicImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var privacyTextview: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .darkGray
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .white
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

// MARK: - Setup UI
private extension CreateNewPostView {
    func setupUI() {
        addSubview(cancelButton)
        addSubview(postButton)
        addSubview(profileImage)
        textStack.addArrangedSubview(messageText)
        textStack.addArrangedSubview(attachmentView)
        attachmentView.addSubview(removeAttachmentButton)
        addSubview(textStack)
        //addSubview(messageText)
        addSubview(newView)
        buttonStack.addArrangedSubview(photoButton)
        buttonStack.addArrangedSubview(clipButton)
        buttonStack.addArrangedSubview(workoutButton)
        addSubview(buttonStack)
        addSubview(privacyButton)
        addSubview(loadingIndicator)
        //messageText.delegate = self
        constrainUI()
        setProfileImage()
        attachmentView.isHidden = true
        removeAttachmentButton.addTarget(self, action: #selector(removeAttachmentButtonTapped(_:)), for: .touchUpInside)
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            postButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            postButton.widthAnchor.constraint(equalToConstant: 72),
            
            profileImage.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 8),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            textStack.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 0),
            textStack.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            //messageText.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 10),
            //messageText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            //messageText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageText.widthAnchor.constraint(equalTo: textStack.widthAnchor),
            messageText.heightAnchor.constraint(equalToConstant: 200),
            
            attachmentView.widthAnchor.constraint(equalTo: textStack.widthAnchor),
            removeAttachmentButton.topAnchor.constraint(equalTo: attachmentView.topAnchor, constant: 1),
            removeAttachmentButton.trailingAnchor.constraint(equalTo: attachmentView.trailingAnchor, constant: -1),
            
            newView.topAnchor.constraint(equalTo: textStack.bottomAnchor,constant: 5),
            newView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            newView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            photoButton.heightAnchor.constraint(equalTo: photoButton.widthAnchor),
            clipButton.heightAnchor.constraint(equalTo: clipButton.widthAnchor),
            workoutButton.heightAnchor.constraint(equalTo: workoutButton.widthAnchor),
            
            buttonStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 30),
            buttonStack.topAnchor.constraint(equalTo: newView.bottomAnchor, constant: 10),
            buttonStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -30),
            
            privacyButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            privacyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
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

extension CreateNewPostView {
    func addImage(_ image: UIImage) {
        attachmentView.isHidden = false
        removeAttachment()
        let imageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.backgroundColor = .clear
            view.image = image
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        attachmentView.insertSubview(imageView, at: 0)
        imageView.centerXAnchor.constraint(equalTo: attachmentView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: attachmentView.widthAnchor, multiplier: 0.8).isActive = true
        imageView.heightAnchor.constraint(equalTo: attachmentView.widthAnchor, multiplier: 0.8).isActive = true
        imageView.topAnchor.constraint(equalTo: attachmentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: attachmentView.bottomAnchor).isActive = true

    }
    
    func addWorkout(_ model: WorkoutModel) {
        removeAttachment()
        attachmentView.isHidden = false
        let workoutView = UIWorkoutView()
        workoutView.translatesAutoresizingMaskIntoConstraints = false
        workoutView.configure(with: model)
        attachmentView.insertSubview(workoutView, at: 0)
        workoutView.topAnchor.constraint(equalTo: attachmentView.topAnchor).isActive = true
        workoutView.widthAnchor.constraint(equalTo: attachmentView.widthAnchor, multiplier: 0.9).isActive = true
        workoutView.centerXAnchor.constraint(equalTo: attachmentView.centerXAnchor).isActive = true
        workoutView.bottomAnchor.constraint(equalTo: attachmentView.bottomAnchor, constant: -10).isActive = true
    }
    func addSavedWorkout(_ model: SavedWorkoutModel) {
        removeAttachment()
        attachmentView.isHidden = false
        let workoutView = UIWorkoutView()
        workoutView.translatesAutoresizingMaskIntoConstraints = false
        workoutView.configure(with: model)
        attachmentView.insertSubview(workoutView, at: 0)
        workoutView.topAnchor.constraint(equalTo: attachmentView.topAnchor).isActive = true
        workoutView.widthAnchor.constraint(equalTo: attachmentView.widthAnchor, multiplier: 0.9).isActive = true
        workoutView.centerXAnchor.constraint(equalTo: attachmentView.centerXAnchor).isActive = true
        workoutView.bottomAnchor.constraint(equalTo: attachmentView.bottomAnchor, constant: -10).isActive = true
    }
    
    func removeAttachment() {
        for view in attachmentView.subviews {
            if view != removeAttachmentButton {
                view.removeFromSuperview()
            }
        }
        attachmentView.isHidden = true
    }
    
    @objc func removeAttachmentButtonTapped(_ sender: UIButton) {
        removeAttachment()
        attachmentView.isHidden = true
    }
    
    public func togglePrivacy(to isPrivate: Bool) {
        privacyButton.setImage(isPrivate ? privateImage : publicImage, for: .normal)
    }
    
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            postButton.isHidden = true
            cancelButton.isHidden = true
            messageText.isUserInteractionEnabled = false
            workoutButton.isUserInteractionEnabled = false
            privacyButton.isUserInteractionEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            postButton.isHidden = false
            cancelButton.isHidden = false
            messageText.isUserInteractionEnabled = true
            workoutButton.isUserInteractionEnabled = true
            privacyButton.isUserInteractionEnabled = true
        }
    }
}
