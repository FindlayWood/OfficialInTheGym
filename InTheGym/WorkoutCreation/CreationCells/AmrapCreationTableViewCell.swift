//
//  AmrapCreationTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AmrapCreationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "AmrapCreationCellID"
    
    // MARK: - Subviews
    var amrapImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "amrap_icon")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 15).isActive = true
        view.widthAnchor.constraint(equalToConstant: 15).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var amrapLabel: UILabel = {
        let label = UILabel()
        label.text = "AMRAP"
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - Setup UI
private extension AmrapCreationTableViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(amrapImage)
        contentView.addSubview(amrapLabel)
        contentView.addSubview(minutesLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            amrapImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            amrapImage.centerYAnchor.constraint(equalTo: amrapLabel.centerYAnchor),
            
            amrapLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            amrapLabel.leadingAnchor.constraint(equalTo: amrapImage.trailingAnchor, constant: 4),
            amrapLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            minutesLabel.topAnchor.constraint(equalTo: amrapLabel.bottomAnchor, constant: 4),
            minutesLabel.leadingAnchor.constraint(equalTo: amrapLabel.leadingAnchor),
            minutesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Functions
extension AmrapCreationTableViewCell {
    public func configure(with amrap: AMRAPModel) {
        minutesLabel.text = (amrap.timeLimit).convertToTime()
    }
}
