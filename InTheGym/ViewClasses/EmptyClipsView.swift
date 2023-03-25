//
//  EmptyClipsView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class EmptyClipsView: UIView {
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "video.fill")
        view.tintColor = .darkColour
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var title: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "No Clips"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var subTitle: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "There are no clips to show. Try changing your search or record some clips of your own to show here."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, title, subTitle])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
private extension EmptyClipsView {
    func setupUI() {
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
