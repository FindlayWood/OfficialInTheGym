//
//  OptionsCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class OptionsCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID = "OptionsCollectionCellreuseID"
    
    // MARK: - Subviews
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup UI
private extension OptionsCollectionCell {
    func setupUI() {
        backgroundColor = .lightColour
        layer.cornerRadius = 40
        layer.borderWidth = 1
        layer.borderColor = Constants.darkColour.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        addSubview(imageView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - Public Configuration
extension OptionsCollectionCell {
    public func configure(with image: UIImage) {
        imageView.image = image
    }
}
