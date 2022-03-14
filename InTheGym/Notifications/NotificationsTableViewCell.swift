//
//  NotificationsTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class NotificationsTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    static let cellID = "NotificationsTableViewCellID"
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.widthAnchor.constraint(equalToConstant: 48).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.imageView?.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
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
}

private extension NotificationsTableViewCell {
    func setupUI() {
        contentView.addSubview(profileImageButton)
        contentView.addSubview(messageLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(timeLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            moreButton.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            moreButton.widthAnchor.constraint(equalToConstant: 30),
            
            messageLabel.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -4),
//            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: moreButton.bottomAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: moreButton.trailingAnchor),
            timeLabel.widthAnchor.constraint(equalTo: moreButton.widthAnchor)
            
        ])
    }
}

extension NotificationsTableViewCell {
    public func configure(with model: NotificationModel) {
        let profileImageSearchModel = ProfileImageDownloadModel(id: model.fromUserID)
        ImageCache.shared.load(from: profileImageSearchModel) { [weak self] result in
            do {
                let image = try result.get()
                self?.profileImageButton.setImage(image, for: .normal)
            } catch {
                self?.profileImageButton.setImage(nil, for: .normal)
            }
        }
        let userSearchModel = UserSearchModel(uid: model.fromUserID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            do {
                let user = try result.get()
                self?.messageLabel.text = "\(user.username) \(model.type.message)"
            } catch {
                self?.messageLabel.text = "There was an error loading this notification."
            }
        }
        timeLabel.text = Date(timeIntervalSince1970: model.time).timeAgo()
    }
}
