//
//  UIClipThumbnailsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UIClipThumbnailsView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    
    var thumbnailOne: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.offWhiteColour.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var thumbnailTwo: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.offWhiteColour.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var thumbnailThree: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.offWhiteColour.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "Clips"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension UIClipThumbnailsView {
    func setupUI() {
        backgroundColor = .thirdColour
        addSubview(thumbnailThree)
        addSubview(thumbnailTwo)
        addSubview(thumbnailOne)
        addSubview(label)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            thumbnailOne.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            thumbnailOne.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            thumbnailTwo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            thumbnailTwo.topAnchor.constraint(equalTo: thumbnailOne.topAnchor),
            thumbnailTwo.leadingAnchor.constraint(equalTo: thumbnailOne.trailingAnchor, constant: -16),
            
            thumbnailThree.topAnchor.constraint(equalTo: thumbnailOne.topAnchor),
            thumbnailThree.leadingAnchor.constraint(equalTo: thumbnailTwo.trailingAnchor, constant: -16),
            
            label.leadingAnchor.constraint(equalTo: thumbnailThree.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Configuration
extension UIClipThumbnailsView {
    public func configure(with clips: [WorkoutClipModel]?) {
        guard let firstClip = clips?.first else {
            thumbnailOne.isHidden = true
            thumbnailTwo.isHidden = true
            thumbnailThree.isHidden = true
            label.isHidden = true
            return}
        thumbnailOne.isHidden = false
        label.isHidden = false
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: firstClip.clipKey)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
            let image = try? result.get()
            self?.thumbnailOne.image = image
        }
        
        if clips?.count ?? 0 > 1 {
            guard let secondClip = clips?[1] else {return}
            thumbnailTwo.isHidden = false
            let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: secondClip.clipKey)
            ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
                let image = try? result.get()
                self?.thumbnailTwo.image = image
            }
        } else {
            thumbnailTwo.isHidden = true
        }
        
        if clips?.count ?? 0 > 2 {
            guard let thirdClip = clips?.last else {return}
            thumbnailThree.isHidden = false
            let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: thirdClip.clipKey)
            ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
                let image = try? result.get()
                self?.thumbnailThree.image = image
            }
        } else {
            thumbnailThree.isHidden = true
        }
    }
}
