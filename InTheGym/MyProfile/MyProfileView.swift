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
    private var infoViewTopAnchor: NSLayoutConstraint!

    private var segementPos: segemntPosition = .bottom
    
    // MARK: - Subviews
    var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.heightAnchor.constraint(equalToConstant: 38).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "MYPROFILE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var moreButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var notificationsButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "bell.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var groupsButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "person.3.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var infoView: UIProfileInfoView = {
        let view = UIProfileInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    var segmentControl: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: .zero, buttonTitles: ["Posts", "Clips", "Workouts"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    var containerView: UIView = {
        let view = UIView()
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
        clipsToBounds = true
        backgroundColor = .white
        addSubview(infoView)
        addSubview(topBackgroundView)
        addSubview(iconLabel)
        addSubview(moreButton)
        addSubview(notificationsButton)
        addSubview(groupsButton)
//        addSubview(profileImageView)
//        addSubview(followerView)
//        addSubview(nameUsernameView)
//        addSubview(bioLabel)
        addSubview(segmentControl)
//        addSubview(tableview)
        addSubview(containerView)
        configureUI()
    }
    
    func configureUI() {
//        infoView.frame = CGRect(x: 0, y: 38, width: Constants.screenSize.width, height: 300)
        infoViewTopAnchor = infoView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8)
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconLabel.heightAnchor.constraint(equalToConstant: 30),
            
            moreButton.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            notificationsButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -12),
            notificationsButton.topAnchor.constraint(equalTo: moreButton.topAnchor),
            
            groupsButton.trailingAnchor.constraint(equalTo: notificationsButton.leadingAnchor, constant: -12),
            groupsButton.topAnchor.constraint(equalTo: moreButton.topAnchor),
            
            infoViewTopAnchor,
//            infoView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
//            profileImageView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
//            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//
//            profileImageView.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
//            profileImageView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
//
//            followerView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
//            followerView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
//            followerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//
//            nameUsernameView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
//            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
//            nameUsernameView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//
//            bioLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
//            bioLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            bioLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            segmentControl.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 4),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0),
            segmentControl.heightAnchor.constraint(equalToConstant: 30),
            
            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
//            tableview.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
//            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
//            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
//            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
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
    
    func scroll(to offset: CGFloat) {
        switch segementPos {
        case .top:
            if offset < 0 {
                infoViewTopAnchor.constant = 8
                segementPos = .bottom
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        case .bottom:
            if offset > 0 {
                infoViewTopAnchor.constant = 8 - infoView.frame.height
                segementPos = .top
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
}

enum segemntPosition {
    case top
    case bottom
}
