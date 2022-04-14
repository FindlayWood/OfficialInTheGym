//
//  UIProfileInfoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UIProfileInfoView: UIView {
    
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var profileImageView: UIButton = {
        let view = UIButton()
//        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = (Constants.screenSize.width * 0.35) / 2
        view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35).isActive = true
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var nameUsernameView: UINameUsernameSubView = {
        let view = UINameUsernameSubView()
        view.nameLabel.textAlignment = .center
        view.usernameLabel.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var followerView: UIUserFollowerSubView = {
        let view = UIUserFollowerSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageView, nameUsernameView, followerView, bioLabel])
        stack.axis = .vertical
        stack.alignment = .center
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
private extension UIProfileInfoView {
    func setupUI() {
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: stack)
    }
}

// MARK: - Public Configuration
extension UIProfileInfoView {
    public func configure(with user: Users) {
        nameUsernameView.configure(with: user)
        followerView.configure(admin: user.admin)
        bioLabel.text = user.profileBio
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
    public func setFollowerCount(to count: Int) {
        followerView.setFollowers(to: count)
    }
    public func setFollowingCount(to count: Int) {
        followerView.setFollowing(to: count)
    }
}
