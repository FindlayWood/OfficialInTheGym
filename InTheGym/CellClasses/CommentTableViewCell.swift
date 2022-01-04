//
//  CommentTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let cellID: String = "CommentTableViewCellID"
    
    // MARK: - Subviews
    var profileImageButton: UIProfileImageButton = {
        let view = UIProfileImageButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.textColor = .darkGray
        view.sizeToFit()
        view.backgroundColor = .offWhiteColour
        view.layer.cornerRadius = 5
        view.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageButton.reset()
    }
}
// MARK: - Configure
private extension CommentTableViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageTextView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 8),
            usernameButton.topAnchor.constraint(equalTo: profileImageButton.topAnchor),
            usernameButton.heightAnchor.constraint(equalToConstant: 24),
            
            timeLabel.leadingAnchor.constraint(equalTo: usernameButton.trailingAnchor, constant: 4),
            timeLabel.centerYAnchor.constraint(equalTo: usernameButton.centerYAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 12),
            
            messageTextView.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor),
            messageTextView.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 8),
            messageTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -5),
            messageTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Public Setup
extension CommentTableViewCell {
    public func setup(with comment: Comment) {
        profileImageButton.set(for: comment.posterID)
        usernameButton.setTitle(comment.username, for: .normal)
        timeLabel.text = (Date(timeIntervalSince1970: (comment.time) / 1000)).timeAgo()
        messageTextView.text = comment.message
    }
}

