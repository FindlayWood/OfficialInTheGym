//
//  YearlySubscriptionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class YearlySubscriptionView: UIView {
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Yearly"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "£29.99"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var selectionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .darkColour
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
private extension YearlySubscriptionView {
    func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkColour.cgColor
        backgroundColor = .secondarySystemBackground
        addSubview(titleLabel)
        addSubview(priceLabel)
        addSubview(selectionButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            priceLabel.widthAnchor.constraint(equalTo: widthAnchor),
            
            selectionButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            selectionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
// MARK: - Public Config
extension YearlySubscriptionView {
    public func setSelection(to selected: Bool) {
        if selected {
            selectionButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        } else {
            selectionButton.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        }
    }
}
