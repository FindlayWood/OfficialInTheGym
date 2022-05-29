//
//  LastThreeScoresView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class LastThreeScoresView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Last 3 Scores"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.alignment = .center
        view.spacing = 8
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
private extension LastThreeScoresView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        addSubview(titleLabel)
        addSubview(stackView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    func createNewLabel(with score: Int) -> UILabel {
        let newLabel = UILabel()
        newLabel.font = .systemFont(ofSize: 20, weight: .bold)
        newLabel.textColor = .label
        newLabel.textAlignment = .center
        newLabel.text = score.description
        newLabel.backgroundColor = Constants.rpeColors[score - 1]
        newLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        newLabel.layer.cornerRadius = 25
        newLabel.layer.masksToBounds = true
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }
}
// MARK: - Public Configuration
extension LastThreeScoresView {
    public func configure(with scores: [Int]) {
        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
        }
        for score in scores {
            let label = createNewLabel(with: score)
            stackView.addArrangedSubview(label)
        }
    }
}

