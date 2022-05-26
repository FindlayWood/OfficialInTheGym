//
//  TagAndExerciseCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class TagAndExerciseCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID: String = "tagAndExerciseCellReuseID"
    
    // MARK: - Subviews
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.image = UIImage(named: "tag_icon")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tagNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
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
private extension TagAndExerciseCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        contentView.addSubview(exerciseLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(tagNameLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            exerciseLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            exerciseLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            exerciseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            tagNameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            tagNameLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor)
        ])
    }
}
// MARK: - Public Config
extension TagAndExerciseCell {
    public func configure(with model: TagAndExerciseCellModel) {
        exerciseLabel.text = model.exercise
        tagNameLabel.text = "#" + model.tag
    }
}
