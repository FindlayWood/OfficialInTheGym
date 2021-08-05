//
//  ExerciseStatsSectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseStatsSectionCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Constants.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var statLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Constants.font
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
        selectionStyle = .none
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(statLabel)
        constrainView()
    }
    private func constrainView() {
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        
                                     statLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     statLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)])
    }
    func setUI(with model: SectionCellModel) {
        titleLabel.text = model.title
        statLabel.text = model.data
    }
}
