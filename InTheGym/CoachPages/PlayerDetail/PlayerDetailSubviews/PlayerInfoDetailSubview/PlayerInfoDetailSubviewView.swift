//
//  PlayerInfoDetailSubviewView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerInfoDetailSubviewView: UIView {
    // MARK: - Subviews
    var infoView: UIProfileInfoView = {
        let view = UIProfileInfoView()
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
private extension PlayerInfoDetailSubviewView {
    func setupUI() {
        addSubview(infoView)
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
