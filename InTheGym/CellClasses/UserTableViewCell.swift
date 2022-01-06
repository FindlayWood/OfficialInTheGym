//
//  UserCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class UserTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "UserTableViewCell"
    private let imageDimension: CGFloat = 60
    
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
        label.textColor = Constants.darkColour
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
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
    
}

// MARK: - Setup Methods
private extension UserTableViewCell {
    func setUpUI() {
        //layer.cornerRadius = 10
        selectionStyle = .none
        backgroundColor = .white
        addSubview(profileImage)
        addSubview(fullNameLabel)
        addSubview(usernameLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     profileImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
                                     profileImage.heightAnchor.constraint(equalToConstant: imageDimension),
                                     profileImage.widthAnchor.constraint(equalToConstant: imageDimension),
        
                                     fullNameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor),
                                     fullNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
        
                                     usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 2),
                                     usernameLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor)])
        
//        let heightConstraint = profileImage.heightAnchor.constraint(equalToConstant: imageDimension)
//        heightConstraint.priority = UILayoutPriority(999)
//        heightConstraint.isActive = true
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
        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] returnedImage in
            guard let self = self else {return}
            if let image = returnedImage {
                self.profileImage.image = image
            }
        }
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
