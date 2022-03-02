//
//  GroupHomePageInfoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupHomePageInfoTableViewCell: UITableViewCell {
    
    // MARK: - Subviews
//    var membersView: GroupCellView = {
//        let view = GroupCellView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    var separatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    var workoutsView: GroupCellView = {
//        let view = GroupCellView()
//        view.isUserInteractionEnabled = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    var membersView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.configureView(image: UIImage(named: "groups_icon")!, label: "Members")
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workoutsView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.configureView(image: UIImage(named: "benchpress_icon")!, label: "Workouts")
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
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
    
    // MARK: - Properties
    static let cellID = "groupCellID"
    var delegate: GroupHomePageProtocol!
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - SetUp UI
private extension GroupHomePageInfoTableViewCell {
    func setupUI() {
        selectionStyle = .none
//        imageViewStack.addArrangedSubview(membersView)
//        imageViewStack.addArrangedSubview(workoutsView)
//        mainStack.addArrangedSubview(imageViewStack)
//        mainStack.addArrangedSubview(manageButton)
        contentView.addSubview(mainStack)
        //contentView.addSubview(imageViewStack)
        //contentView.addSubview(membersView)
        //contentView.addSubview(separatorView)
        //contentView.addSubview(workoutsView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutsTapped))
        workoutsView.addGestureRecognizer(tap)
        let memebersTap = UITapGestureRecognizer(target: self, action: #selector(membersTapped))
        membersView.addGestureRecognizer(memebersTap)
        manageButton.addTarget(self, action: #selector(manageGroupTapped(_:)), for: .touchUpInside)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            
//                                    membersView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//                                     membersView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
//                                     membersView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
//                                     membersView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -20),
                                     
//                                     separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//                                     separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
//                                     separatorView.widthAnchor.constraint(equalToConstant: 1),
//                                     separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
//                                     separatorView.heightAnchor.constraint(equalToConstant: 95),
                                     
//                                     workoutsView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
//                                     workoutsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//                                     workoutsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
//                                     workoutsView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 20)
        ])
    }
}

// MARK: - Actions
private extension GroupHomePageInfoTableViewCell {
    @objc func workoutsTapped() {
        delegate.goToWorkouts()
    }
    @objc func membersTapped(){
        delegate.showGroupMembers()
    }
    @objc func manageGroupTapped(_ sender: UIButton) {
        delegate.manageGroup()
    }
}

extension GroupHomePageInfoTableViewCell {
    public func configureForLeader(_ leaderID: String) {
        manageButton.isHidden = !(leaderID == UserDefaults.currentUser.uid)
    }
}

