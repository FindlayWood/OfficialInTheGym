//
//  EmomCreationTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class EmomCreationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "EmomCreationCellID"
    
    // MARK: - Subviews
    var emomImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "emom_icon")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 15).isActive = true
        view.widthAnchor.constraint(equalToConstant: 15).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var emomLabel: UILabel = {
        let label = UILabel()
        label.text = "EMOM"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var minutesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup UI
private extension EmomCreationTableViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(emomImage)
        contentView.addSubview(emomLabel)
        contentView.addSubview(minutesLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            emomImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            emomImage.centerYAnchor.constraint(equalTo: emomLabel.centerYAnchor),
            
            emomLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            emomLabel.leadingAnchor.constraint(equalTo: emomImage.trailingAnchor, constant: 4),
            emomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            minutesLabel.topAnchor.constraint(equalTo: emomLabel.bottomAnchor, constant: 4),
            minutesLabel.leadingAnchor.constraint(equalTo: emomLabel.leadingAnchor),
            minutesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Functions
extension EmomCreationTableViewCell {
    public func configure(with emom: EMOMModel) {
        minutesLabel.text = (emom.timeLimit * 60).convertToTime()
    }
}
