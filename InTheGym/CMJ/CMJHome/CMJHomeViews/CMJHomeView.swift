//
//  CMJHomeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI
import UIKit

extension CMJHomeViewController {
    class Display: UIView {
        // MARK: - Properties
        
        // MARK: - Subviews
        var scrollView: UIScrollView = {
            let view = UIScrollView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        var stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            stack.alignment = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        var newJumpButton: UIButton = {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .large
            config.cornerStyle = .medium
            config.title = "Record New Jump"
            config.attributedTitle?.font = .preferredFont(forTextStyle: .body, weight: .medium)
            config.baseBackgroundColor = .systemBackground
            config.baseForegroundColor = .label
            config.titleAlignment = .leading
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .left
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        var jumpsButton: UIButton = {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .large
            config.cornerStyle = .medium
            config.title = "My Jumps"
            config.attributedTitle?.font = .preferredFont(forTextStyle: .body, weight: .medium)
            config.baseBackgroundColor = .systemBackground
            config.baseForegroundColor = .label
            config.titleAlignment = .leading
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .left
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        var myMeasurementsButton: UIButton = {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .large
            config.cornerStyle = .medium
            config.title = "My Measurements"
            config.attributedTitle?.font = .preferredFont(forTextStyle: .body, weight: .medium)
            config.baseBackgroundColor = .systemBackground
            config.baseForegroundColor = .label
            config.titleAlignment = .leading
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .left
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        var helpButton: UIButton = {
            var config = UIButton.Configuration.plain()
            config.title = "Help"
            config.attributedTitle?.font = .preferredFont(forTextStyle: .body, weight: .medium)
            config.titleAlignment = .leading
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .left
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
        
        // MARK: - Configure
        func setupUI() {
            backgroundColor = .secondarySystemBackground
            addSubview(scrollView)
            scrollView.addSubview(stack)
            configureUI()
        }
        func configureUI() {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
                stack.centerXAnchor.constraint(equalTo: centerXAnchor),
                stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
            ])
        }
        
        func updateMeasurementsButton() {
            myMeasurementsButton.configurationUpdateHandler = { button in
                var config = button.configuration
                config?.image = UIImage(systemName: "exclamationmark.circle.fill")
                config?.imagePlacement = .trailing
                config?.imagePadding = 10
                config?.baseForegroundColor = .red
                button.configuration = config
            }
        }
        
        func updateMeasurementButtonEnabled() {
            myMeasurementsButton.configurationUpdateHandler = { button in
                var config = button.configuration
                config?.image = nil
                config?.baseForegroundColor = .label
                button.configuration = config
            }
        }
    }
    class TitleView: UIView {
        // MARK: - Subviews
        var imageView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(named: "bolt_icon")
            view.contentMode = .scaleAspectFit
            view.backgroundColor = .clear
            view.heightAnchor.constraint(equalToConstant: 60).isActive = true
            view.widthAnchor.constraint(equalToConstant: 60).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        var titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Welcome to the CMJ"
            label.font = .preferredFont(forTextStyle: .title1, weight: .bold)
            label.textColor = .darkColour
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var messageLabel: UILabel = {
            let label = UILabel()
            label.text = "CMJ (counter movement jump) is where you can measure your current lower body power output."
            label.font = .preferredFont(forTextStyle: .body, weight: .medium)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        lazy var stack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [imageView, messageLabel])
            stack.axis = .vertical
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
        // MARK: - Configure
        func setupUI() {
            addSubview(stack)
            configureUI()
        }
        
        func configureUI() {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }
}
