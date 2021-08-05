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
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        layer.cornerRadius = 10
        backgroundColor = Constants.offWhiteColour
        addSubview(titleLabel)
        constrainView()
    }
    private func constrainView() {
        NSLayoutConstraint.activate([titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
                                     titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)])
    }
    func setUI(with title: String) {
        titleLabel.text = title
    }
}
