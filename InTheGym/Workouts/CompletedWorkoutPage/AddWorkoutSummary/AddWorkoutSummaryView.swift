//
//  AddWorkoutSummaryView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AddWorkoutSummaryView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var summaryText: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        view.textColor = .secondaryLabel
        view.tintColor = .darkColour
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
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
// MARK: - Configure
private extension AddWorkoutSummaryView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(dismissButton)
        addSubview(saveButton)
        addSubview(summaryText)
        addSubview(characterCountLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.widthAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            summaryText.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),
            summaryText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            summaryText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            summaryText.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: summaryText.trailingAnchor),
            characterCountLabel.topAnchor.constraint(equalTo: summaryText.bottomAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension AddWorkoutSummaryView {
    public func setCharacterCount(_ count: Int) {
        guard count <= 1000 else {return}
        characterCountLabel.text = (1000 - count).description
    }
}
