//
//  ScoresPieChartView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class ScoresPieChartView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Scores"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var pieChartView: PieChartView = {
        let view = PieChartView()
        view.legend.enabled = false
        view.drawEntryLabelsEnabled = false
        view.holeColor = .systemBackground
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activitiyIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension ScoresPieChartView {
    func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        backgroundColor = .systemBackground
        addSubview(titleLabel)
        addSubview(pieChartView)
        addSubview(activitiyIndicator)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            pieChartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            pieChartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pieChartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pieChartView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        addFullConstraint(to: activitiyIndicator)
        
    }
}
