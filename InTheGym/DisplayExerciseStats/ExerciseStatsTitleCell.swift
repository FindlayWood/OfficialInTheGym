//
//  ExerciseStatsTitleCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseStatsTitleCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "ExerciseStatsTitleCellID"
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkColour
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
// MARK: - Setup UI
private extension ExerciseStatsTitleCell {
    func setupUI() {
        selectionStyle = .none
        layer.cornerRadius = 10
        backgroundColor = .offWhiteColour
        addSubview(titleLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                                     titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                                     titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)])
    }
}
// MARK: - Public Configuration
extension ExerciseStatsTitleCell {
    public func configure(with model: ExerciseStatsModel) {
        titleLabel.text = model.exerciseName
    }
}
