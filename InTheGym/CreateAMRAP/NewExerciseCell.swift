//
//  NewExerciseCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class NewExerciseCell: UITableViewCell {
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.text = "Add Exercise"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        backgroundColor = Constants.darkColour
        addSubview(messageLabel)
        constrain()
        layer.cornerRadius = 10
        selectionStyle = .none
    }

    private func constrain() {
        NSLayoutConstraint.activate([messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
}
