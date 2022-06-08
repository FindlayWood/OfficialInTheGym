//
//  DisplayWorkoutStatsCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayWorkoutStatsCell: UICollectionViewCell {
    // MARK: - Properties
    private let imageDimension: CGFloat = 40
    // MARK: - Subviews
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.widthAnchor.constraint(equalToConstant: imageDimension).isActive = true
        image.heightAnchor.constraint(equalToConstant: imageDimension).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    var title: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var stat: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Initialozer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}
// MARK: - Setup UI
private extension DisplayWorkoutStatsCell {
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        addSubview(image)
        addSubview(title)
        addSubview(stat)
        constrainUI()
    }
    private func constrainUI() {
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            stat.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            stat.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
// MARK: - Public Config
extension DisplayWorkoutStatsCell {
    func setupStats(with model: WorkoutStatCellModel) {
        image.image = model.image
        title.text = model.title
        stat.text = model.stat
    }
}
