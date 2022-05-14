//
//  DiscoverSectionHeader.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverSectionHeader: UICollectionReusableView {
    
    // MARK: - Publishers
    var moreButtonTapped = PassthroughSubject<Void,Never>()
    
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
    var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("more", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
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

// MARK: - Setup UI
private extension DiscoverSectionHeader {
    func setupUI() {
        addSubview(label)
        addSubview(moreButton)
        backgroundColor = .systemBackground
        constrainUI()
        moreButton.addTarget(self, action: #selector(moreButtonAction(_:)), for: .touchUpInside)
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    @objc func moreButtonAction(_ sender: UIButton) {
        moreButtonTapped.send(())
    }
}
