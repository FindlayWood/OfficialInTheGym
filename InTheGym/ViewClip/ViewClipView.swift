//
//  ViewClipView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ViewClipView: UIView {
    
    // MARK: - Subviews
    var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var progressBar: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exerciseName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}
// MARK: - Setup UI
private extension ViewClipView {
    func setupUI() {
        addSubview(thumbnailImageView)
        addSubview(loadingIndicator)
        addSubview(progressBar)
        addSubview(bottomView)
        bottomView.addSubview(exerciseName)
        bottomView.addSubview(dateLabel)
        progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: 5)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            
            exerciseName.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            exerciseName.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            exerciseName.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: exerciseName.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
// MARK: - Public Configuration
extension ViewClipView {
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.thumbnailImageView.isHidden = false
            }
        } else {
            loadingIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.thumbnailImageView.alpha = 0
            } completion: { [weak self] _ in
                self?.thumbnailImageView.isHidden = true
                self?.thumbnailImageView.alpha = 1
            }
        }
    }
    public func updateProgressBar(currentTime: Double, videolength: Double) {
        let progress = CGFloat((currentTime) / videolength)
        if progress == 0 {
            self.progressBar.frame = CGRect(x: 0, y: self.safeAreaInsets.top, width: 0, height: 5)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.progressBar.frame = CGRect(x: 0, y: self.safeAreaInsets.top, width: Constants.screenSize.width * progress, height: 5)
            }
        }
    }
    public func setModel(_ clipModel: ClipModel) {
        exerciseName.text = clipModel.exerciseName
        let date = Date(timeIntervalSince1970: clipModel.time)
        dateLabel.text = date.getWorkoutFormat()
    }
}
