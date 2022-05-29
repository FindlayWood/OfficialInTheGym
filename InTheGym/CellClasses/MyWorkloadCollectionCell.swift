//
//  MyWorkloadCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyWorkloadCollectionCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseID: String = "MyWorkloadCollectionCellID"
    // MARK: - Subviews
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var topSeparatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workloadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var rpeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
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
private extension MyWorkloadCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        contentView.addSubview(dateLabel)
        contentView.addSubview(topSeparatorView)
        contentView.addSubview(workloadLabel)
        contentView.addSubview(rpeLabel)
        contentView.addSubview(timeLabel)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            topSeparatorView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            topSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            topSeparatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            
            workloadLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 8),
            workloadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            rpeLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 8),
            rpeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
}
// MARK: - Public Config
extension MyWorkloadCollectionCell {
    public func configure(with model: WorkloadModel) {
        let date = Date(timeIntervalSince1970: model.endTime)
        dateLabel.text = date.getWorkoutFormat()
        workloadLabel.text = model.workload.description
        rpeLabel.text = model.rpe.description
        timeLabel.text = model.timeToComplete.convertToWorkoutTime()
    }
}
