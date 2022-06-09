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
        view.image = UIImage(systemName: "bubble.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
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
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
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
        addSubview(replyStack)
        addSubview(likeStack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            replyStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            replyStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 82),
            replyStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            likeStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            likeStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            likeStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
