//
//  ExerciseMaxHistoryCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseMaxHistoryCollectionCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseID: String = "ExerciseMaxHistoryCollectionCell"
    // MARK: - Subviews
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var maxWeightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
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
private extension ExerciseMaxHistoryCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        contentView.addSubview(dateLabel)
        contentView.addSubview(maxWeightLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            maxWeightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            maxWeightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
}
// MARK: - Public Config
extension ExerciseMaxHistoryCollectionCell {
    public func configure(with model: ExerciseMaxHistoryModel) {
        let date = Date(timeIntervalSince1970: model.time)
        dateLabel.text = date.getWorkoutFormat()
        maxWeightLabel.text = model.weight.description + "kg"
    }
}
