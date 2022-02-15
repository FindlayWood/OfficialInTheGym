//
//  PublicTimelineView.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PublicTimelineView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var profileImageView: UIButton = {
        let view = UIButton()
//        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = (Constants.screenSize.width * 0.35) / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var nameUsernameView: UINameUsernameSubView = {
        let view = UINameUsernameSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var followerView: UIUserFollowerSubView = {
        let view = UIUserFollowerSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var followButton: UIButton = {
        let button = UIButton()
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
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
private extension PublicTimelineView {
    func setupUI() {
        backgroundColor = .white
        addSubview(profileImageView)
        addSubview(followerView)
        addSubview(nameUsernameView)
        addSubview(followButton)
        addSubview(bioLabel)
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            
            followerView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followerView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            followerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            nameUsernameView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameUsernameView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            followButton.topAnchor.constraint(equalTo: followerView.bottomAnchor, constant: 4),
            followButton.leadingAnchor.constraint(equalTo: followerView.leadingAnchor),
            followButton.trailingAnchor.constraint(equalTo: followerView.trailingAnchor),
            followButton.heightAnchor.constraint(equalToConstant: 22),
            
            bioLabel.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bioLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            tableview.topAnchor.constraint(equalTo: bioLabel.bottomAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public Configuration
extension PublicTimelineView {
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
    public func setFollowing(to following: Bool) {
        if following {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.lightColour, for: .normal)
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = UIColor.lightColour.cgColor
            followButton.backgroundColor = .white
            followButton.isUserInteractionEnabled = false
        }
    }
}
