//
//  PlayerDetailView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerDetailView: UIView {
    // MARK: - Properties
    
    var scoreTopAnchor: NSLayoutConstraint!
    var scoreContainerWidthAnchor: NSLayoutConstraint!
    var scoreContainerHeightAnchor: NSLayoutConstraint!
    
    // MARK: - Subviews
    var profileImageView: UIButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = (Constants.screenSize.width * 0.25) / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var nameUsernameView: UINameUsernameSubView = {
        let view = UINameUsernameSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var userBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var scoreContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var workloadContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewWorkoutsButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .darkColour
        button.setTitle("View Workouts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var addWorkoutButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .darkColour
        button.setTitle("Add Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [viewWorkoutsButton,addWorkoutButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
private extension PlayerDetailView {
    func setupUI() {
        backgroundColor = .white
        userBackgroundView.addSubview(profileImageView)
        userBackgroundView.addSubview(nameUsernameView)
        addSubview(userBackgroundView)
//        addSubview(profileImageView)
//        addSubview(nameUsernameView)
        addSubview(scoreContainerView)
        addSubview(workloadContainerView)
        addSubview(buttonStack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            userBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            userBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            profileImageView.topAnchor.constraint(equalTo: userBackgroundView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: userBackgroundView.leadingAnchor, constant: 8),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.25),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.25),
            profileImageView.bottomAnchor.constraint(equalTo: userBackgroundView.bottomAnchor, constant: -8),
            
            nameUsernameView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
//            nameUsernameView.topAnchor.constraint(equalTo: userBackgroundView.topAnchor, constant: 8),
            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameUsernameView.trailingAnchor.constraint(equalTo: userBackgroundView.trailingAnchor, constant: -8),
            
//            nameUsernameView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
//            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
//            nameUsernameView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            scoreContainerView.topAnchor.constraint(equalTo: userBackgroundView.bottomAnchor, constant: 16),
            scoreContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scoreContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scoreContainerView.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.2),
            
            workloadContainerView.topAnchor.constraint(equalTo: scoreContainerView.bottomAnchor, constant: 16),
            workloadContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            workloadContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            workloadContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            workloadContainerView.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.2),
            
            buttonStack.topAnchor.constraint(equalTo: workloadContainerView.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.15),
//            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            
//
        ])
    }
}

// MARK: - Public Configuration
extension PlayerDetailView {
    public func configure(with user: Users) {
        nameUsernameView.configure(with: user)
        let imageDownloader = ProfileImageDownloadModel(id: user.uid)
        ImageCache.shared.load(from: imageDownloader) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let image):
                self.profileImageView.setImage(image, for: .normal)
            case .failure(_):
                self.profileImageView.backgroundColor = .lightGray
            }
        }
    }
}
