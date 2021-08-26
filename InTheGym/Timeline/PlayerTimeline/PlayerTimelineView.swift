//
//  PlayerTimelineView.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PlayerTimelineView: UIView {
    
    // MARK: - Properties
    private let topViewFrame = CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 50)
    
    private let showPostViewFrame = CGRect(x: 0, y: 50, width: Constants.screenSize.width, height: 50)
    private let hidePostViewFrame = CGRect(x: 0, y: 50, width: Constants.screenSize.width, height: 0)
    
    private var tableviewTopAnchor: NSLayoutConstraint!
    
    var isPostViewShowing: Bool = true
    
    // MARK: - Subiviews
    var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "inthegym_icon3")
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "INTHEGYM"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var notifButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 15
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.setImage(UIImage(named: "bell_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var postView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    var profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create a new post...", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .offWhiteColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 90
        view.backgroundColor = Constants.darkColour
        view.register(UINib(nibName: "TimelinePostTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePostTableViewCell")
        view.register(UINib(nibName: "TimelineCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCreatedWorkoutTableViewCell")
        view.register(UINib(nibName: "TimelineCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCompletedTableViewCell")
        view.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
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
// MARK: - Setup UI
private extension PlayerTimelineView {
    func setupUI() {
        backgroundColor = .white
        topView.addSubview(iconImageView)
        topView.addSubview(iconLabel)
        topView.addSubview(notifButton)
        postView.addSubview(profileImageView)
        postView.addSubview(postButton)
        postView.addSubview(spacerView)
        addSubview(topView)
        addSubview(postView)
        addSubview(tableview)
        clipsToBounds = true
        constrainUI()
        fetchProfileImage()
    }
    func constrainUI() {
        topView.frame = topViewFrame
        postView.frame = showPostViewFrame
        tableviewTopAnchor = tableview.topAnchor.constraint(equalTo: topAnchor, constant: 100)
        NSLayoutConstraint.activate([tableviewTopAnchor,
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     
                                     iconImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 5),
                                     iconImageView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
                                     iconLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5),
                                     iconLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
                                     notifButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10),
                                     notifButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
                                     
                                     profileImageView.leadingAnchor.constraint(equalTo: postView.leadingAnchor, constant: 20),
                                     profileImageView.centerYAnchor.constraint(equalTo: postView.centerYAnchor),
                                     
                                     postButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                                     postButton.centerYAnchor.constraint(equalTo: postView.centerYAnchor),
                                     
                                     spacerView.leadingAnchor.constraint(equalTo: postView.leadingAnchor),
                                     spacerView.bottomAnchor.constraint(equalTo: postView.bottomAnchor),
                                     spacerView.trailingAnchor.constraint(equalTo: postView.trailingAnchor),
                                     spacerView.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    func fetchProfileImage() {
        let userID = FirebaseAuthManager.currentlyLoggedInUser.uid
        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] image in
            guard let self = self else {return}
            if image != nil {
                self.profileImageView.image = image
            }
        }
    }
}

extension PlayerTimelineView {
    public func showTopView() {
        isPostViewShowing = true
        tableviewTopAnchor.constant = 100
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.postView.frame = self.showPostViewFrame
            self.layoutIfNeeded()
        }
    }
    public func hideTopView() {
        isPostViewShowing = false
        tableviewTopAnchor.constant = 50
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.postView.frame = self.hidePostViewFrame
            self.layoutIfNeeded()
        }
    }
}
