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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workoutsView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.configureView(image: UIImage(named: "benchpress_icon")!, label: "Workouts")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageViewStack: UIStackView = {
        let view = UIStackView()
        //view.distribution = .equalSpacing
        view.spacing = 40
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
    
    var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
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
        imageViewStack.addArrangedSubview(membersView)
        imageViewStack.addArrangedSubview(workoutsView)
        mainStack.addArrangedSubview(imageViewStack)
        mainStack.addArrangedSubview(manageButton)
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
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            
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
    public func configureForLeader(_ isLeader: Bool) {
        manageButton.isHidden = !isLeader
    }
}

