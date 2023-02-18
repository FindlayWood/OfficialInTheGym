//
//  WorkoutDiscoveryCommentsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit

class WorkoutDiscoveryCommentsView: UIView {
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
    var tableview: UITableView = {
        let view = UITableView()
        view.register(DescriptionTableViewCell.self, forCellReuseIdentifier: DescriptionTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var buttonView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
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
// MARK: - Configure
private extension WorkoutDiscoveryCommentsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(buttonView)
        buttonView.addSubview(ratingLabel)
        buttonView.addSubview(ratingCountLabel)
        buttonView.addSubview(addRatingButton)
        addSubview(tableview)
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
            
            tableview.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 8),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            plusButton.bottomAnchor.constraint(equalTo: tableview.bottomAnchor, constant: -16)
        ])
    }
}
// MARK: - Public Config
extension WorkoutDiscoveryCommentsView {
    public func setRating(to rating: Double) {
        ratingLabel.text = "Rating: " + rating.description
    }
    public func setRatingCount(to count: Int) {
        ratingCountLabel.text = count.description + " ratings"
    }
}
