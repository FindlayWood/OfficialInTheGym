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
        label.text = "(0 ratings)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addRatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var exerciseStampsView: ExerciseStampsView = {
        let view = ExerciseStampsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        button.tintColor = .lightColour
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var buttonView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tableview])
        stack.axis = .vertical
        stack.alignment = .center
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
private extension DescriptionsView {
    func setupUI() {
        addSubview(buttonView)
        buttonView.addSubview(ratingLabel)
        buttonView.addSubview(ratingCountLabel)
        buttonView.addSubview(addRatingButton)
        addSubview(stack)
        addSubview(plusButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            buttonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            buttonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            ratingLabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 16),

            ratingLabel.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 8),
            ratingLabel.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -16),
            
            addRatingButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            addRatingButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -8),
            
            ratingCountLabel.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 4),
            ratingCountLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            
            stack.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: tableview.trailingAnchor, constant: -8),
            plusButton.bottomAnchor.constraint(equalTo: tableview.bottomAnchor, constant: -16)
        ])
    }
}
// MARK: - Public Config
extension DescriptionsView {
    public func setRating(to rating: Double) {
        ratingLabel.text = "Rating: " + rating.description
    }
    public func setRatingCount(to count: Int) {
        ratingCountLabel.text = "(" + count.description + " ratings)"
    }
}
