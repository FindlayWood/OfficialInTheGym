//
//  PostTextSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostTextSubview: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var textView: UILabel = {
        let view = UILabel()
        view.font = .preferredFont(forTextStyle: .body, weight: .semibold)
        view.textColor = .label
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
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
private extension PostTextSubview {
    func setupUI() {
        addSubview(textView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
