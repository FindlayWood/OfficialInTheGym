//
//  PostCellView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/12/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostCellView: UIView {
    
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.1
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var stampView: UserStampsView = {
        let view = UserStampsView()
        return view
    }()
    lazy var usernamStampHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernameButton,stampView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var usernameTimeVstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernamStampHStack,timeLabel])
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
//    var postUserView: PostUserSubview = {
//        let view = PostUserSubview()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postTextView: PostTextSubview = {
        let view = PostTextSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postWorkoutView: PostWorkoutSubview = {
        let view = PostWorkoutSubview()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postInteractionsView: PostInteractionsSubview = {
        let view = PostInteractionsSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var vstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernameTimeVstack, postTextView, postWorkoutView, postInteractionsView])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()
    lazy var postStack: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [profileImageButton, vstack])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
//    lazy var fullPostStack: UIStackView = {
//        let stack = UIStackView(arrangedSubviews: [postUserView, postTextView, postWorkoutView, postInteractionsView])
//        stack.axis = .vertical
//        stack.alignment = .leading
//        stack.distribution = .equalSpacing
//        stack.spacing = 8
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
    
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
private extension PostCellView {
    func setupUI() {
        backgroundColor = .systemBackground
//        addSubview(fullPostStack)
        addSubview(postStack)
        constrainUI()
    }
    func constrainUI() {
//        let workoutAnchor = postWorkoutView.workoutView.heightAnchor.constraint(equalToConstant: 130)
//        workoutAnchor.priority = .defaultLow
//        let spacerHeight = spacerView.heightAnchor.constraint(equalToConstant: 44)
//        spacerHeight.priority = .defaultLow
        NSLayoutConstraint.activate([
            postStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            postStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            postStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            postStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//            spacerHeight,
//            workoutAnchor,
            postWorkoutView.widthAnchor.constraint(equalTo: vstack.widthAnchor),
            postInteractionsView.widthAnchor.constraint(equalTo: vstack.widthAnchor)
        ])
    }
}
