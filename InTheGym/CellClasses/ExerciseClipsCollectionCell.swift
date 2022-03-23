//
//  ExerciseClipsCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import Foundation
import UIKit

final class ExerciseClipsCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID = "ExerciseClipsCollectionCellreuseID"
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 15
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
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
private extension ExerciseClipsCollectionCell {
    func setupUI() {
        contentView.clipsToBounds = true
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(profileImageButton)
        backgroundColor = .lightGray
        addViewShadow(with: .darkColour)
        layer.cornerRadius = 8
        contentView.layer.cornerRadius = 8
        configureUI()
    }
    
    func configureUI() {
//        addFullConstraint(to: thumbnailImageView)
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        ])
    }
}

// MARK: - Public Configuration
extension ExerciseClipsCollectionCell {
    public func configure(with model: ClipModel) {
        let profileImageModel = ProfileImageDownloadModel(id: model.userID)
        ImageCache.shared.load(from: profileImageModel) { [weak self] result in
            let image = try? result.get()
            self?.profileImageButton.setImage(image, for: .normal)
        }
        
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: model.id)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
            let image = try? result.get()
            self?.thumbnailImageView.image = image
        }
    }
}
