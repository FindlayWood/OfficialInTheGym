//
//  ProfileHeaderView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileHeaderView: UICollectionReusableView {
    
    // MARK: - Publishers
    @Published var selectedIndex: Int = 0
    
    // MARK: - Properties
    static let reuseIdentifier = "ProfileHeaderViewReuseID"
    static let elementID = "headerElement"
    
    // MARK: - Subviews
    var segmentControl: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: .zero, buttonTitles: ["Posts"])
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

// MARK: - Setup UI
private extension ProfileHeaderView {
    func setupUI() {
        addSubview(segmentControl)
        backgroundColor = .white
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0),
            segmentControl.heightAnchor.constraint(equalToConstant: 30),
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
