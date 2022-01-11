//
//  ExerciseCreationTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseCreationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "ExerciseCreationCellID"
    
    // MARK: - Subviews
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var setsLabel: UILabel = {
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
private extension ExerciseCreationTableViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(exerciseLabel)
        contentView.addSubview(setsLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            exerciseLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            exerciseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            exerciseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            setsLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 4),
            setsLabel.leadingAnchor.constraint(equalTo: exerciseLabel.leadingAnchor),
            setsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Functions
extension ExerciseCreationTableViewCell {
    public func configure(with exercise: ExerciseModel) {
        exerciseLabel.text = exercise.exercise
        setsLabel.text = "\(exercise.sets?.description ?? "") Sets"
    }
}
