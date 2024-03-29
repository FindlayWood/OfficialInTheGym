//
//  UIProfileInfoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UIProfileInfoView: UIView {
    // MARK: - Subviews
    var profileImageView: UIButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = (Constants.screenSize.width * 0.35) / 2
        view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35).isActive = true
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35).isActive = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
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
    var userStampsView: UserStampsView = {
        let view = UserStampsView()
        return view
    }()
    var followButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.3).isActive = true
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.color = .white
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageView, nameUsernameView, followerView, userStampsView, followButton, bioLabel])
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
        userStampsView.configure(with: user)
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
        if UserDefaults.currentUser == user && SubscriptionManager.shared.isSubscribed {
            profileImageView.layer.borderColor = UIColor.premiumColour.cgColor
        } else {
            profileImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    public func setFollowerCount(to count: Int) {
        followerView.setFollowers(to: count)
    }
    public func setFollowingCount(to count: Int) {
        followerView.setFollowing(to: count)
    }
    func addFollowButton(_ following: Bool) {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
        followButton.setTitle(following ? "Following" : "Follow", for: .normal)
        followButton.setTitleColor(following ? .darkColour : .white, for: .normal)
        followButton.backgroundColor = following ? .white : .darkColour
        followButton.isUserInteractionEnabled = following ? false : true
        followButton.layer.borderWidth = following ? 2 : 0
        followButton.layer.borderColor = following ? UIColor.darkColour.cgColor : nil
    }
    public func setFollowButton(to stage: FollowButtonStage) {
        followButton.isHidden = false
        switch stage {
        case .loading:
            setLoadingButton()
        case .following:
            addFollowButton(true)
        case .follow:
            addFollowButton(false)
        }
    }
    func setLoadingButton() {
        followButton.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: followButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: followButton.centerYAnchor)
        ])
    }
}

enum FollowButtonStage {
    case loading
    case following
    case follow
}
