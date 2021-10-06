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
        button.backgroundColor = .red
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.layer.cornerRadius = 15
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
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
    
    
    var privacyButton: UIButton = {
        let button = UIButton()
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
        //messageText.delegate = self
        constrainUI()
        attachmentView.isHidden = true
        removeAttachmentButton.addTarget(self, action: #selector(removeAttachmentButtonTapped(_:)), for: .touchUpInside)
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            postButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            postButton.widthAnchor.constraint(equalToConstant: 70),
            
            textStack.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 10),
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
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
            buttonStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -30)
        ])
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
    
    func addWorkout(_ workout: WorkoutDelegate) {
        attachmentView.isHidden = false
        removeAttachment()
        let workoutView = UIWorkoutView()
        workoutView.translatesAutoresizingMaskIntoConstraints = false
        workoutView.configure(with: workout)
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
    }
    
    @objc func removeAttachmentButtonTapped(_ sender: UIButton) {
        removeAttachment()
        attachmentView.isHidden = true
    }
    
}
