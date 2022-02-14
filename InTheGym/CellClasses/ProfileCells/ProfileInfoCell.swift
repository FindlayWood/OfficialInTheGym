//
//  ProfileInfoCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileInfoCell: UITableViewCell {
    
    // MARK: - Publisher
    var optionSelected = PassthroughSubject<ProfileOptions,Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Cell Identifier
    static let cellID = "ProfileInfoCellID"
    
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
    
    var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
//    override func layoutSubviews() {
//        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
//        profileImageView.clipsToBounds = true
//    }
}

// MARK: - Setup UI
private extension ProfileInfoCell {
    func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameUsernameView)
        contentView.addSubview(followerView)
        contentView.addSubview(bioLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.35),
            
            followerView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            followerView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            followerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            nameUsernameView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameUsernameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameUsernameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bioLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bioLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            
        ])
    }
}

// MARK: - Public Configuration
extension ProfileInfoCell {
    public func configure(with model: UserProfileModel) {
//        nameUsernameView.configure(with: model.user)
//        followerView.configure(followers: model.followers, following: model.following, admin: model.user.admin)
//        bioLabel.text = model.user.profileBio
//        let imageDownloader = ProfileImageDownloadModel(id: model.user.uid)
//        ImageCache.shared.load(from: imageDownloader) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let image):
//                self.profileImageView.setImage(image, for: .normal)
//            case .failure(_):
//                self.profileImageView.backgroundColor = .lightGray
//            }
//        }
    }
}
