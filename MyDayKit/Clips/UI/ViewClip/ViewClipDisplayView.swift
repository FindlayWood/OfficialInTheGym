//
//  ViewClipDisplayView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/03/2026.
//

import UIKit

final class ViewClipDisplayView: UIView {
    
    // MARK: - Subviews
    
    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let pauseOverlay: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pause.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progressTintColor = .white
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progress.isHidden = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .black
        
        addSubview(videoContainerView)
        addSubview(thumbnailImageView)
        addSubview(pauseOverlay)
        addSubview(progressBar)
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            // Video container - full screen
            videoContainerView.topAnchor.constraint(equalTo: topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Thumbnail - same size as video container
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Pause overlay - center
            pauseOverlay.centerXAnchor.constraint(equalTo: centerXAnchor),
            pauseOverlay.centerYAnchor.constraint(equalTo: centerYAnchor),
            pauseOverlay.widthAnchor.constraint(equalToConstant: 80),
            pauseOverlay.heightAnchor.constraint(equalToConstant: 80),
            
            // Progress bar - top edge
            progressBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 3),
            
            // Loading Indicator - center
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
