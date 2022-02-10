//
//  LiveWorkoutPlusCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class LiveWorkoutPlusCollectionCell: FullWidthCollectionViewCell {
    
    // MARK: - Publishers
    var plusTappedPublisher = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    static let reuseID = "LiveWorkoutPlusCollectionCellreuseID"
    
    // MARK: - Subviews
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Set Workout"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(plusTapped(_:)), for: .touchUpInside)
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
    
}
// MARK: - Configure
private extension LiveWorkoutPlusCollectionCell {
    func setupUI() {
        contentView.addSubview(plusButton)
        backgroundColor = .clear
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            plusButton.widthAnchor.constraint(equalToConstant: 100),
            plusButton.heightAnchor.constraint(equalToConstant: 100),
            
            plusButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25)
        ])
    }
    @objc func plusTapped(_ sender: UIButton) {
        plusTappedPublisher.send(())
    }
}
