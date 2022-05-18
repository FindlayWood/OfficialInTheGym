//
//  WorkoutViewCompletedHStack.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutViewCompletedHStack: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var completedLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .lightColour
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [completedLabel,dateLabel])
        stack.axis = .horizontal
        stack.alignment = .center
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
private extension WorkoutViewCompletedHStack {
    func setupUI() {
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        let completedHeight = completedLabel.heightAnchor.constraint(equalToConstant: 24)
        completedHeight.priority = UILayoutPriority(999)
        let dateHeight = dateLabel.heightAnchor.constraint(equalToConstant: 24)
        dateHeight.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            completedHeight,
            dateHeight,
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
