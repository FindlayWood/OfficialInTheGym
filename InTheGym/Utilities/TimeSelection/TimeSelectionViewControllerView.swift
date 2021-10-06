//
//  TimeSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimeSelectionViewControllerView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Time"
        label.font = Constants.font
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension TimeSelectionViewControllerView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(tableview)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            tableview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
