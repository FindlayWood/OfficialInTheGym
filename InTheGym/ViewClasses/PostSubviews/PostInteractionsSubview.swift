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
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
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
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
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
