//
//  PerformanceIntroView.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
//

import UIKit
import SwiftUI

extension PerformanceIntroViewController {
    final class Display: UIView {
        // MARK: - Properties
        
        // MARK: - Subviews
        var scrollView: UIScrollView = {
            let view = UIScrollView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        var stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            stack.alignment = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
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
        // MARK: - Configure
        func setupUI() {
            backgroundColor = .secondarySystemBackground
            addSubview(scrollView)
            scrollView.addSubview(stack)
            configureUI()
        }
        func configureUI() {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
                stack.centerXAnchor.constraint(equalTo: centerXAnchor),
                stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
            ])
        }
    }
}


struct PerformanceIntroView: View {
    
    var viewModel: PerformanceIntroViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0..<25) { _ in
                    Text("heelo ronald")
                }
                VStack {
                    Text("hello world")
                    Spacer()
                    Text("What is going on?")
                }
            }
            .navigationTitle("Hello")
        }
    }
}
