//
//  CircuitCreationTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CircuitCreationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "CircuitCreationCellID"
    
    // MARK: - Subviews
    var circuitImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "circuit_icon")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 15).isActive = true
        view.widthAnchor.constraint(equalToConstant: 15).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var circuitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var exercisesLabel: UILabel = {
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
private extension CircuitCreationTableViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(circuitImage)
        contentView.addSubview(circuitLabel)
        contentView.addSubview(exercisesLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            circuitImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            circuitImage.centerYAnchor.constraint(equalTo: circuitLabel.centerYAnchor),
            
            circuitLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            circuitLabel.leadingAnchor.constraint(equalTo: circuitImage.trailingAnchor, constant: 4),
            circuitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            exercisesLabel.topAnchor.constraint(equalTo: circuitLabel.bottomAnchor, constant: 4),
            exercisesLabel.leadingAnchor.constraint(equalTo: circuitLabel.leadingAnchor),
            exercisesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Functions
extension CircuitCreationTableViewCell {
    public func configure(with circuit: CircuitModel) {
        circuitLabel.text = circuit.circuitName
        exercisesLabel.text = "\(circuit.exercises.count) exercises"
    }
}
