//
//  CommentInteractionView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class CommentInteractionView: UIView {
    
    var taggedUserButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [likeButton, taggedUserButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
private extension CommentInteractionView {
    func setupUI() {
        addSubview(hstack)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: topAnchor),
            hstack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hstack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hstack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
