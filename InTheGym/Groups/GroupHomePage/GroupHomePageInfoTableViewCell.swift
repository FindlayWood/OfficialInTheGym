//
//  GroupHomePageInfoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class GroupHomePageInfoTableViewCell: UITableViewCell {
    
    // MARK: - Publishers
    var actionPublisher: PassthroughSubject<GroupInfoCellAction,Never> = PassthroughSubject<GroupInfoCellAction,Never>()
    
    // MARK: - Properties
    static let cellID = "GroupHomePageInfoTableViewCellCellID"
    
    // MARK: - Subviews
    
    var membersView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.configureView(image: UIImage(named: "groups_icon")!, label: "Members")
//        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workoutsView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.configureView(image: UIImage(named: "benchpress_icon")!, label: "Workouts")
//        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageViewStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [membersView, workoutsView])
        //view.distribution = .equalSpacing
        view.alignment = .fill
        view.spacing = 32
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var manageButton: UIButton = {
       let button = UIButton()
        button.setTitle("Manage Group", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .lightColour
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageViewStack, manageButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        actionPublisher = PassthroughSubject<GroupInfoCellAction,Never>()
    }
}

// MARK: - SetUp UI
private extension GroupHomePageInfoTableViewCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(mainStack)
        constrainView()
        initTargets()
    }
    func constrainView() {
        let memebersHeightAnchor = membersView.heightAnchor.constraint(equalToConstant: 90)
        memebersHeightAnchor.priority = UILayoutPriority(999)
        let workoutsHeightAnchor = workoutsView.heightAnchor.constraint(equalToConstant: 90)
        workoutsHeightAnchor.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageViewStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            memebersHeightAnchor,
            workoutsHeightAnchor,
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    func initTargets() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutsTapped))
        workoutsView.addGestureRecognizer(tap)
        let memebersTap = UITapGestureRecognizer(target: self, action: #selector(membersTapped))
        membersView.addGestureRecognizer(memebersTap)
        manageButton.addTarget(self, action: #selector(manageGroupTapped(_:)), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension GroupHomePageInfoTableViewCell {
    @objc func workoutsTapped() {
        actionPublisher.send(.workouts)
    }
    @objc func membersTapped(){
        actionPublisher.send(.members)
    }
    @objc func manageGroupTapped(_ sender: UIButton) {
        actionPublisher.send(.manage)
    }
}

extension GroupHomePageInfoTableViewCell {
    public func configureForLeader(_ leaderID: String) {
        manageButton.isHidden = !(leaderID == UserDefaults.currentUser.uid)
    }
}

