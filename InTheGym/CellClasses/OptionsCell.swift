//
//  OptionsCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

final class OptionsCell: FullWidthCollectionViewCell {
    
    // MARK: - Properties
    var iconDimension: CGFloat = 30
    
    static let reuseID = "OptionsCellreuseID"
    
    // MARK: - Subviews
    // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkColour
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = "Title"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // ICONS
    lazy var optionIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "coach_icon")
        view.tintColor = .darkColour
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
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
private extension OptionsCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        addViewShadow(with: .darkColour)
        layer.cornerRadius = 8
        contentView.addSubview(titleLabel)
        contentView.addSubview(optionIcon)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            optionIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            optionIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.trailingAnchor.constraint(equalTo: optionIcon.leadingAnchor, constant: -4),
        ])
    }
}

// MARK: - Public Configuration
extension OptionsCell {
    public func configure(with option: Options) {
        titleLabel.text = option.rawValue
        optionIcon.image = option.image
        if option == .delete {
            optionIcon.tintColor = .red
        } else {
            optionIcon.tintColor = .darkColour
        }
    }
}
