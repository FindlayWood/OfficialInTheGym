//
//  PostCellView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/12/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostCellView: UIView {
    
    var postUserView: PostUserSubview = {
        let view = PostUserSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    
    lazy var fullPostStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postUserView, spacerView, postTextView, postWorkoutView, postInteractionsView])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
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
// MARK: - Setup UI
private extension PostCellView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(fullPostStack)
        constrainUI()
    }
    func constrainUI() {
        let workoutAnchor = postWorkoutView.workoutView.heightAnchor.constraint(equalToConstant: 130)
        workoutAnchor.priority = .defaultLow
        let spacerHeight = spacerView.heightAnchor.constraint(equalToConstant: 44)
        spacerHeight.priority = .defaultLow
        NSLayoutConstraint.activate([
            fullPostStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            fullPostStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            fullPostStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            fullPostStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            spacerHeight,
            workoutAnchor,
            postWorkoutView.widthAnchor.constraint(equalTo: fullPostStack.widthAnchor),
            postInteractionsView.widthAnchor.constraint(equalTo: fullPostStack.widthAnchor)
        ])
    }
}
