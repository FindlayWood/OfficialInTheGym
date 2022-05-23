//
//  UserCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class UserTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "UserTableViewCell"
    private let imageDimension: CGFloat = 60
    private var viewModel = UserCellViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
    lazy var profileImage: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = imageDimension / 2
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
        initViewModel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
    }
    
}

// MARK: - Setup Methods
private extension UserTableViewCell {
    func setUpUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        addSubview(profileImage)
        addSubview(fullNameLabel)
        addSubview(usernameLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImage.heightAnchor.constraint(equalToConstant: imageDimension),
            profileImage.widthAnchor.constraint(equalToConstant: imageDimension),
            profileImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            
            usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
//            usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    func initViewModel() {
        viewModel.$profileImageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setProfileImage(with: $0)}
            .store(in: &subscriptions)
    }
    func setProfileImage(with data: Data?) {
        if let data = data {
            let image = UIImage(data: data)
            profileImage.image = image
        } else {
            profileImage.image = nil
        }
    }
}

// MARK: - Configure Cell
extension UserTableViewCell {
    public func configureCell(with user: Users) {
        let firstName = user.firstName
        let lastName = user.lastName
        let username = user.username
        let userID = user.uid
        fullNameLabel.text = firstName + " " + lastName
        usernameLabel.text = username
        viewModel.loadProfileImage(for: user)
//        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] returnedImage in
//            guard let self = self else {return}
//            if let image = returnedImage {
//                self.profileImage.image = image
//            }
//        }
    }
    public func selected() {
        fullNameLabel.textColor = Constants.darkColour
        backgroundColor = .white
    }
    public func notSelected() {
        fullNameLabel.textColor = .lightGray
        backgroundColor = Constants.offWhiteColour
    }
}
