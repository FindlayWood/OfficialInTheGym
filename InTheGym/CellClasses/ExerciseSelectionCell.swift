//
//  ExerciseSelectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseSelectionCell: UICollectionViewCell {
    // MARK: - Publishers
    var infoButtonTapped = PassthroughSubject<Void,Never>()
    // MARK: - Properties
    static let reuseIdentifier = "ExerciseSelectionCellID"
    var indexPath: IndexPath!
    var delegate: ExerciseSelectionProtocol!
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
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
    override func prepareForReuse() {
        infoButtonTapped = PassthroughSubject<Void,Never>()
    }
}
// MARK: - Setup UI
private extension ExerciseSelectionCell {
    func setupUI() {
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .systemBackground
        contentView.addSubview(label)
        contentView.addSubview(infoButton)
        constrainUI()
        infoButton.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -4),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    @objc func infoButtonAction(_ sender: UIButton) {
        delegate.infoButtonSelected(at: indexPath)
    }
}
// MARK: - Public Configuration
extension ExerciseSelectionCell {
    func configure(with exercise: String) {
        label.text = exercise
    }
}
