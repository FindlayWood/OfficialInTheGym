//
//  UserStampsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UserStampsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var verifiedImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .lightColour
        view.image = UIImage(systemName: "checkmark.seal.fill")
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var eliteImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .goldColour
        view.image = UIImage(systemName: "checkmark.seal.fill")
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eliteImageView, verifiedImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
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
private extension UserStampsView {
    func setupUI() {
        addSubview(stack)
        verifiedImageView.isHidden = true
        eliteImageView.isHidden = true
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
// MARK: - Public Config
extension UserStampsView {
    public func configure(with user: Users) {
        if let verifiedAccount = user.verifiedAccount {
            verifiedImageView.isHidden = !verifiedAccount
        }
        if let eliteTrainerAccount = user.eliteAccount {
            eliteImageView.isHidden = !eliteTrainerAccount
        }
    }
}
