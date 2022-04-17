//
//  ProfileInfoCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit
import Combine

class ProfileInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Publishers
    
    // MARK: - Properties
    static let reuseID = "ProfileInfoCollectionViewCell"
    
    var viewModel = ProfileInfoCellViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
    var infoView: UIProfileInfoView = {
        let view = UIProfileInfoView()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}

// MARK: - Setup UI
private extension ProfileInfoCollectionViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(infoView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            infoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
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

// MARK: - Public Configuration
extension ProfileInfoCollectionViewCell {
    func configure(with user: Users) {
//        infoView.configure(with: user)
        viewModel.user = user
        infoView.configure(with: user)
        initViewModel()
    }
}

