//
//  MyProfileView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MyProfileView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "MYPROFILE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        view.register(ProfileInfoCell.self, forCellReuseIdentifier: ProfileInfoCell.cellID)
        view.register(ProfileOptionsCell.self, forCellReuseIdentifier: ProfileOptionsCell.cellID)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.tableFooterView = UIView()
        view.separatorInset = .zero
        view.layoutMargins = .zero
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
private extension MyProfileView {
    func setupUI() {
        backgroundColor = .white
        addSubview(iconLabel)
        addSubview(profileImageView)
        addSubview(followerView)
        addSubview(nameUsernameView)
        addSubview(bioLabel)
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            iconLabel.heightAnchor.constraint(equalToConstant: 30),
            
            profileImageView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            
            followerView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followerView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            followerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            nameUsernameView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameUsernameView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            bioLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
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
extension MyProfileView {
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
