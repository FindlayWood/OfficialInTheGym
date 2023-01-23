//
//  ExerciseTagCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseTagCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID: String = "ExerciseTagCellReuseID"
    
    // MARK: - Subviews
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        view.image = UIImage(systemName: "tag", withConfiguration: symbolConfiguration)
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tagNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
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
private extension ExerciseTagCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        contentView.addSubview(imageView)
        contentView.addSubview(tagNameLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tagNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tagNameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            tagNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}
// MARK: - Public Configuration
extension ExerciseTagCell {
    public func configure(with model: ExerciseTagReturnModel) {
        tagNameLabel.text = "#" + model.tag
    }
}
