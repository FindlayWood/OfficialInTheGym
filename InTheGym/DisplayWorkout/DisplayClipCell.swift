//
//  DisplayClipCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class DisplayClipCell: UICollectionViewCell, ClipCollectionCell {
    
    // MARK: - Properties
    static var reuseID = "DisplayClipCellReuseID"
    
    // MARK: - Subviews
    var thumbnailImageView: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil
    }
}
private extension DisplayClipCell {
    func setUpView() {
        backgroundColor = .lightGray
        layer.cornerRadius = 40
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true
        addSubview(thumbnailImageView)
        constrainView()
    }
    
    func constrainView() {
        NSLayoutConstraint.activate([thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
                                     thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

// MARK: - Public Configuarion
extension DisplayClipCell {
    func configure(with model: WorkoutClipModel) {
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: model.clipKey)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
            let image = try? result.get()
            self?.thumbnailImageView.image = image
        }
    }
}
