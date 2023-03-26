//
//  PostInteractionsSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostInteractionsSubview: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var postTaggedUsersView: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var replyCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var replyImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "bubble.left")
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var replyStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [replyImageView,replyCountLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var likeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [likeButton,likeCountLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
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
private extension PostInteractionsSubview {
    func setupUI() {
        addSubview(postTaggedUsersView)
        addSubview(replyStack)
        addSubview(likeStack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            postTaggedUsersView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            postTaggedUsersView.centerYAnchor.constraint(equalTo: centerYAnchor),
            likeStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            likeStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            likeStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            replyStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            replyStack.trailingAnchor.constraint(equalTo: likeStack.leadingAnchor, constant: -16),
            replyStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}
