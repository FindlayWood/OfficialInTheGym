//
//  DiscoverSectionHeader.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class DiscoverSectionHeader: UICollectionReusableView {
    
    // MARK: - Properties
    static let reuseIdentifier = "DiscoverSectionHeaderreuseID"
    static let elementID = "headerElement"
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .black
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

// MARK: - Setup UI
private extension DiscoverSectionHeader {
    func setupUI() {
        addSubview(label)
        backgroundColor = .white
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
