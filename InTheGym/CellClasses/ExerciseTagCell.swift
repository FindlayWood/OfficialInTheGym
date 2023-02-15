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
    var newView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "tag")
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tagNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, tagNameLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        backgroundColor = .clear
        layer.cornerRadius = 8
        contentView.addSubview(newView)
        newView.addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            newView.topAnchor.constraint(equalTo: contentView.topAnchor),
            newView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: newView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: newView.bottomAnchor, constant: -16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: newView.trailingAnchor, constant: -8)
        ])
    }
}
// MARK: - Public Configuration
extension ExerciseTagCell {
    public func configure(with model: ExerciseTagReturnModel) {
        tagNameLabel.text = "#" + model.tag
    }
}
