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
        contentView.addSubview(membersView)
        //contentView.addSubview(separatorView)
        contentView.addSubview(workoutsView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutsTapped))
        workoutsView.addGestureRecognizer(tap)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([membersView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     membersView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     membersView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
                                     membersView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -20),
                                     
//                                     separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//                                     separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
//                                     separatorView.widthAnchor.constraint(equalToConstant: 1),
//                                     separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
//                                     separatorView.heightAnchor.constraint(equalToConstant: 95),
                                     
                                     workoutsView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     workoutsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     workoutsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
                                     workoutsView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 20)
        ])
    }
}

// MARK: - Actions
private extension GroupHomePageInfoTableViewCell {
    @objc func workoutsTapped() {
        delegate.goToWorkouts()
    }
}

