//
//  CoachRequestTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CoachRequestTableViewCell: UserTableViewCell {
    // MARK: - Publishers
    var sendRequestAction = PassthroughSubject<Void,Never>()
    // MARK: - Properties
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    // MARK: - Subviews
    var requestButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.darkColour.cgColor
        button.layer.borderWidth = 2
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        sendRequestAction = PassthroughSubject<Void,Never>()
    }
}
// MARK: - Configure
private extension CoachRequestTableViewCell {
    func setupUI() {
        contentView.addSubview(requestButton)
        configureUI()
        requestButton.addTarget(self, action: #selector(sendRequestButtonAction(_:)), for: .touchUpInside)
        impactGenerator.prepare()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            requestButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            requestButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            requestButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
    }
    @objc func sendRequestButtonAction(_ sender: UIButton) {
        impactGenerator.impactOccurred()
        requestButton.setTitle("Sent", for: .normal)
        requestButton.backgroundColor = .white
        requestButton.setTitleColor(.darkColour, for: .normal)
        requestButton.isUserInteractionEnabled = false
        sendRequestAction.send(())
    }
}
// MARK: - Public Config
extension CoachRequestTableViewCell {
    public func configure(with model: CoachRequestCellModel) {
        super.configureCell(with: model.user)
        requestButton.setTitle(model.requestStatus.rawValue, for: .normal)
        switch model.requestStatus {
        case .accepted:
            requestButton.backgroundColor = .white
            requestButton.setTitleColor(.darkColour, for: .normal)
            requestButton.isUserInteractionEnabled = false
        case .sent:
            requestButton.backgroundColor = .white
            requestButton.setTitleColor(.darkColour, for: .normal)
            requestButton.isUserInteractionEnabled = false
        case .none:
            requestButton.backgroundColor = .darkColour
            requestButton.setTitleColor(.white, for: .normal)
            requestButton.isUserInteractionEnabled = true
        }
    }
}
