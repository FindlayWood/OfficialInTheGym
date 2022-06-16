//
//  ProfileInfoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileInfoTableViewCell: UITableViewCell {
    
    // MARK: - Publishers
    var actionPublisher = PassthroughSubject<ProfileInfoActions,Never>()
    
    // MARK: - Properties
    static let cellID = "ProfileInfoTableViewCellID"
    
    var viewModel = ProfileInfoCellViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
    var infoView: UIProfileInfoView = {
        let view = UIProfileInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipButton: ProfileButton = {
        let button = ProfileButton()
        button.configure(with: "Clips", and: UIImage(named: "clip_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var workoutsButton: ProfileButton = {
        let button = ProfileButton()
        button.configure(with: "Saved Workouts", and: UIImage(named: "benchpress_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [clipButton,workoutsButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
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
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}

// MARK: - Setup UI
private extension ProfileInfoTableViewCell {
    func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        contentView.addSubview(infoView)
        contentView.addSubview(stack)
        constrainUI()
        addTargets()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            infoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            infoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            stack.topAnchor.constraint(equalTo: infoView.bottomAnchor,constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    func addTargets() {
        infoView.followerView.followerCountButton.addTarget(self, action: #selector(followersTapped(_:)), for: .touchUpInside)
        infoView.followerView.followingCountButton.addTarget(self, action: #selector(followingTapped(_:)), for: .touchUpInside)
        infoView.followButton.addTarget(self, action: #selector(followButtonAction(_:)), for: .touchUpInside)
        clipButton.addTarget(self, action: #selector(clipsTapped(_:)), for: .touchUpInside)
        workoutsButton.addTarget(self, action: #selector(savedWorkoutsTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(stampsTapAction(_:)))
        infoView.userStampsView.addGestureRecognizer(tap)
    }
    func initViewModel() {
        
        viewModel.$followerCount
            .sink { [weak self] in self?.infoView.setFollowerCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$followingCount
            .sink { [weak self] in self?.infoView.setFollowingCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$isFollowing
            .compactMap { $0 }
            .sink { [weak self] following in
                if following {
                    self?.infoView.setFollowButton(to: .following)
                } else {
                    self?.infoView.setFollowButton(to: .follow)
                }}
            .store(in: &subscriptions)
        
        viewModel.getFollowerCount()
        viewModel.checkUserModel()
    }
}
// MARK: - Actions
private extension ProfileInfoTableViewCell {
    @objc func clipsTapped(_ sender: UIButton) {
        actionPublisher.send(.clips)
    }
    @objc func savedWorkoutsTapped(_ sender: UIButton) {
        actionPublisher.send(.savedWorkouts)
    }
    @objc func followersTapped(_ sender: UIButton) {
        actionPublisher.send(.followers)
    }
    @objc func followingTapped(_ sender:  UIButton) {
        actionPublisher.send(.following)
    }
    @objc func followButtonAction(_ sender: UIButton) {
        infoView.setFollowButton(to: .loading)
        viewModel.followButtonAction()
    }
    @objc func stampsTapAction(_ sender: UIButton) {
        actionPublisher.send(.stamps)
    }
}
// MARK: - Public Configuration
extension ProfileInfoTableViewCell {
    func configure(with user: Users) {
        viewModel.user = user
        infoView.configure(with: user)
        initViewModel()
    }
}
