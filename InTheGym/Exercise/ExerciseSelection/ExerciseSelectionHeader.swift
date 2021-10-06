//
//  ExerciseSelectionHeader.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseSelectionHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "headerViewIdentifier"
    static let elementID = "headerElement"
    
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

private extension ExerciseSelectionHeader {
    func setupUI() {
        addSubview(label)
        backgroundColor = .white
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension ExerciseSelectionHeader {
    public func setup(section: Int) {
        switch section {
        case 0:
            label.text = "Upper Body"
        case 1:
            label.text = "Lower Body"
        case 2:
            label.text = "Core"
        case 3:
            label.text = "Cardio"
        case 4:
            label.text = "Circuit"
        case 5:
            label.text = "AMRAP"
        default:
            label.text = "EMOM"
        }
    }
}
