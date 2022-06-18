//
//  OnBoardMainView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

extension OnBoardMainViewController {
    // MARK: - Display
    func initDisplay() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .lightColour
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = initialPage
        
        skipButton.setTitleColor(.darkColour, for: .normal)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
    }
    func configureUI() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
