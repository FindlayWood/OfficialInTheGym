//
//  ViewClipViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Combine

enum clipViewingState {
    case fullScreen
    case dismissed
}

class ViewClipViewController: UIViewController {
    // MARK: - Properties
    weak var newCoordinator: ClipProfileCustomCoordinator?
    
    var player: AVPlayer?
    
    var display = ViewClipView()
    
    var paused: Bool = false
    
    var viewModel = ViewClipViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var originalFrame = view.bounds
    private lazy var disappearingFrame = CGRect(x: 0, y: Constants.screenSize.height, width: Constants.screenSize.width, height: view.frame.height)
    private lazy var originPoint = originalFrame.origin

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        addObservers()
        initTargets()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Download Thumbnail
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: viewModel.keyClipModel.clipKey)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
            let image = try? result.get()
            self?.display.thumbnailImageView.image = image
        }
    }
    // MARK: - Targets
    func initTargets() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        display.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        display.addGestureRecognizer(pan)
    }
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.playerPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.setPlayer($0) }
            .store(in: &subscriptions)
        
        viewModel.premiumAccountPublisher
            .sink { [weak self] in self?.premiumAccountAlert() }
            .store(in: &subscriptions)
        
        viewModel.$clipModel
            .compactMap { $0 }
            .sink { [weak self] in self?.display.setModel($0) }
            .store(in: &subscriptions)
            
        viewModel.fetchClip()
        viewModel.fetchClipModel()
    }
    
    func setPlayer(_ player: AVPlayer) {
        print(Thread.current)
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.backgroundColor = UIColor.clear.cgColor
        display.layer.insertSublayer(layer, at: 0)
        player.play()
        addTimerObserver()
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(clipFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    // MARK: - Alert
    func premiumAccountAlert() {
        print("need premium account")
    }
    // TODO: - Move to view model
    func addTimerObserver() {
        guard let player = viewModel.playerPublisher.value else {return}
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else {return}
            if player.currentItem?.status == .readyToPlay {
                let currentTime = CMTimeGetSeconds(player.currentTime())
                
                let seconds = Double(currentTime)
                guard let currentVideoLength = ((player.currentItem?.asset) as? AVURLAsset)?.duration.seconds else {return}
                self.display.updateProgressBar(currentTime: seconds, videolength: currentVideoLength)
            }
        }
    }
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: display)
        
        if translation.y > 0 {
            self.view.bounds = CGRect(x: 0, y: originPoint.y - translation.y, width: Constants.screenSize.width, height: Constants.screenSize.height)
        }
        
        switch sender.state {
        case .ended:
            if translation.y > 0 || sender.velocity(in: display).y > 3000 {
                snapToState(.dismissed)
            } else {
                snapToState(.fullScreen)
            }
        default:
            break
        }
    }
    func snapToState(_ state: clipViewingState) {
        switch state {
        case .fullScreen:
            UIView.animate(withDuration: 0.3) {
                self.view.bounds = self.originalFrame
            }
        case .dismissed:
            guard let player = viewModel.playerPublisher.value else {return}
            player.pause()
            newCoordinator?.dismissVC()
        }
    }
}
// MARK: - Actions
private extension ViewClipViewController {
    @objc func clipFinished() {
        display.thumbnailImageView.isHidden = false
        newCoordinator?.dismissVC()
    }
    
    @objc func togglePause() {
        guard let player = viewModel.playerPublisher.value else {return}
        if paused {
            player.play()
            paused.toggle()
        } else {
            player.pause()
            paused.toggle()
        }
    }
    @objc func back() {
        guard let player = viewModel.playerPublisher.value else {return}
        player.pause()
        display.thumbnailImageView.isHidden = false
        newCoordinator?.dismissVC()
    }
}
