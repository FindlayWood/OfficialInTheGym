//
//  PostTaggedUsersSubview.swift
//  InTheGym
//
//  Created by Findlay-Personal on 10/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class PostTaggedUsersSubview: UIView {
    
    // MARK: - Subviews
    var personImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.fill"))
        view.tintColor = .darkColour
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
private extension PostTaggedUsersSubview {
    func setupUI() {
        addSubview(personImage)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            personImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            personImage.topAnchor.constraint(equalTo: topAnchor),
            personImage.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            
        ])
    }
}
