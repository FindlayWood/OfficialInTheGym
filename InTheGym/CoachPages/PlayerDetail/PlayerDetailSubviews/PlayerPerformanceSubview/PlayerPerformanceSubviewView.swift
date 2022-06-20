//
//  PlayerPerformanceSubviewView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerPerformanceSubviewView: UIView {
    // MARK: - Subviews
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "monitor_icon")
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 1
        label.text = "Monitor Player Performance"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Monitor the performance of this player. Workload, optimal ratio, freshness, and more..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var vstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel,messageLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView,vstack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
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
private extension PlayerPerformanceSubviewView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        addSubview(hstack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            hstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            hstack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
