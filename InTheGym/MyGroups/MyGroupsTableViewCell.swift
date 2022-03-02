//
//  MyGroupsTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyGroupsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static var cellID: String = "MyGroupsTableViewCellID"
    
    // MARK: - Subviews
    var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var groupImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.layer.cornerRadius = 50
        view.clipsToBounds = false
        view.layer.masksToBounds = true
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .offWhiteColour
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var createdByLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .lightGray
//        label.text = "Created by..."
        label.textAlignment = .center
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.contentView.frame.insetBy(dx: 10, dy: 10)
    }


}
// MARK: - Configure
private extension MyGroupsTableViewCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
        contentView.addSubview(groupImageView)
        contentView.addSubview(groupNameLabel)
        contentView.addSubview(createdByLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 100),
            
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 200),
            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            groupImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            groupImageView.centerYAnchor.constraint(equalTo: topView.bottomAnchor),
            
            groupNameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 16),
            groupNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            groupNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            createdByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            createdByLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            createdByLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 8),
            createdByLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
        ])
    }
}

// MARK: - Public Configuration
extension MyGroupsTableViewCell {
    public func configure(with group: GroupModel) {
        groupNameLabel.text = group.username
        let userSearchModel = UserSearchModel(uid: group.leader)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            self?.createdByLabel.text = user.username
        }
        ImageAPIService.shared.getProfileImage(for: group.uid) { [weak self] profileImage in
            if let image = profileImage {
                self?.groupImageView.image = image
            }
        }
    }
}
