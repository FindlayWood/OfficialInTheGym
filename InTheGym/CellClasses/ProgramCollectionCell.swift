//
//  ProgramCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ProgramCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let reuseID = "ProgramCollectionCellreuseID"
    
    // MARK: - Subviews
    // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = "Title"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var creatorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = "Made By"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exerciseCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = "12 weeks"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // ICONS
    lazy var creatorIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "coach_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bookView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.6)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
// MARK: - Configure
private extension ProgramCollectionCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        addViewShadow(with: .darkGray)
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        contentView.addSubview(titleLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(exerciseCountLabel)
        contentView.addSubview(creatorIcon)
        contentView.addSubview(bookView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            creatorIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 4),
            creatorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 8),
            exerciseCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            bookView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bookView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
    }
}

// MARK: - Public Configuration
extension ProgramCollectionCell {
    public func configure(with model: ProgramModel) {
        titleLabel.text = model.title
        exerciseCountLabel.text = model.weeks.count.description + " Weeks"
        if model.creatorID == UserDefaults.currentUser.uid {
            creatorLabel.text = UserDefaults.currentUser.username
        } else {
            let searchModel = UserSearchModel(uid: model.creatorID)
            UsersLoader.shared.load(from: searchModel) { [weak self] result in
                guard let user = try? result.get() else {return}
                self?.creatorLabel.text = user.username
            }
        }
    }
    public func configure(with model: SavedProgramModel) {
        titleLabel.text = model.title
        exerciseCountLabel.text = model.weeks.count.description + " Weeks"
        if model.creatorID == UserDefaults.currentUser.uid {
            creatorLabel.text = UserDefaults.currentUser.username
        } else {
            let searchModel = UserSearchModel(uid: model.creatorID)
            UsersLoader.shared.load(from: searchModel) { [weak self] result in
                guard let user = try? result.get() else {return}
                self?.creatorLabel.text = user.username
            }
        }
    }
}
