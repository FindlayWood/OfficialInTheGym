//
//  DescriptionsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DescriptionsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Rating:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var ratingCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "0 ratings"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addRatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var tableview: UITableView = {
        let view = UITableView()
        view.register(DescriptionTableViewCell.self, forCellReuseIdentifier: DescriptionTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 100)), for: .normal)
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension DescriptionsView {
    func setupUI() {
        addSubview(ratingLabel)
        addSubview(ratingCountLabel)
        addSubview(addRatingButton)
        addSubview(tableview)
        addSubview(plusButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            addRatingButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            addRatingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            ratingLabel.centerYAnchor.constraint(equalTo: addRatingButton.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            ratingCountLabel.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            ratingCountLabel.bottomAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: -2),
            
            tableview.topAnchor.constraint(equalTo: addRatingButton.bottomAnchor, constant: 8),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: tableview.trailingAnchor, constant: -5),
            plusButton.bottomAnchor.constraint(equalTo: tableview.bottomAnchor, constant: -5)
        ])
    }
}
// MARK: - Public Config
extension DescriptionsView {
    public func setRating(to rating: Double) {
        ratingLabel.text = "Rating: " + rating.description
    }
    public func setRatingCount(to count: Int) {
        ratingCountLabel.text = count.description + " ratings"
    }
}
