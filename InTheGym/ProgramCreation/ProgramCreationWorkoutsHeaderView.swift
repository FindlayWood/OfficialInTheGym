//
//  ProgramCreationWorkoutsHeaderView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ProgramCreationWorkoutsHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let reuseID = "ProgramCreationWorkoutsHeaderViewreuseID"
    static let elementID = "headerElement"
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .black
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

// MARK: - Setup UI
private extension ProgramCreationWorkoutsHeaderView {
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

// MARK: - Public Configuration
extension ProgramCreationWorkoutsHeaderView {
    public func setup(section: Int) {
        switch section {
        case 0:
            label.text = "Workouts"
        case 1:
            label.text = "Add New Workout"
        default:
            label.text = "Workouts"
        }
    }
}
