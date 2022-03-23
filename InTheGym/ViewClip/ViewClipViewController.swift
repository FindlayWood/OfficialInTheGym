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
    
    weak var coordinator: ViewClipFlow?
    
    var player: AVPlayer?
    
//    var storageURL: String!
    
    var display = ViewClipView()
    
//    var informationView = ViewClipBottomView()
    
//    var flashView = FlashView()
    
//    private var bottomViewHeight = Constants.screenSize.height * 0.2
    
    var paused: Bool = false
    
//    var exerciseName: String!
    
//    var creatorID: String!
    
//    var workoutID: String!
    
    var viewModel = ViewClipViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var originalFrame = view.bounds
    private lazy var disappearingFrame = CGRect(x: 0, y: Constants.screenSize.height, width: Constants.screenSize.width, height: view.frame.height)
    private lazy var originPoint = originalFrame.origin

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .clear
        initViewModel()
//        showLoading()
        addObservers()
        initTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
//        display.exerciseName.text = exerciseName
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: viewModel.keyClipModel.clipKey)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { [weak self] result in
            let image = try? result.get()
            self?.display.thumbnailImageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        viewModel.playerPublisher
//            .compactMap { $0 }
//            .sink { [weak self] in self?.startPlayer($0) }
//            .store(in: &subscriptions)
        
//        startVideo()
//
//        guard let currentVideoLength = ((player.currentItem?.asset) as? AVURLAsset)?.duration.seconds else {return}
//        let currentTime = player.currentTime()
//        print(currentTime)
//        print(currentVideoLength)
    }
    

    // MARK: - Targets
    func initTargets() {
        display.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        display.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        display.addGestureRecognizer(pan)
        display.moreButton.addTarget(self, action: #selector(showInformation), for: .touchUpInside)
    }
    
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.playerPublisher
            .compactMap { $0 }
            .sink { [weak self] in self?.setPlayer($0) }
            .store(in: &subscriptions)
        
        viewModel.assetPublisher
            .sink { [weak self] in self?.setAsset($0)}
            .store(in: &subscriptions)
        
        viewModel.premiumAccountPublisher
            .sink { [weak self] in self?.premiumAccountAlert() }
            .store(in: &subscriptions)
            
        viewModel.fetchClip()
    }
    
    func setAsset(_ asset: AVAsset) {
        player = .init(playerItem: .init(asset: asset))
        player?.replaceCurrentItem(with: .init(asset: asset))
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.backgroundColor = UIColor.green.cgColor
        view.layer.addSublayer(layer)
        player?.play()
    }
    
    func setPlayer(_ player: AVPlayer) {
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.backgroundColor = UIColor.red.cgColor
        view.layer.addSublayer(layer)
        display.setLoading(to: false)
        player.play()
        addTimerObserver()
    }
    
    func startPlayer(_ player: AVPlayer) {
        print(player.currentItem?.status)
        if player.currentItem?.status == .readyToPlay {
            player.play()
        }
    }
 
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(clipFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
//    func startVideo() {
//        guard let playerURL = URL(string: storageURL) else {return}
//        player = AVPlayer(url: playerURL)
//
//        let layer = AVPlayerLayer(player: player)
//        layer.frame = view.bounds
//        layer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(layer)
////        display.removeLoadingIndicator()
//        player.play()
//        addTimerObserver()
//    }
    
    // MARK: - Actions
    @objc func clipFinished() {
        self.dismiss(animated: true, completion: nil)
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
        self.dismiss(animated: true, completion: nil)
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
            if translation.y > Constants.screenSize.height / 2 || sender.velocity(in: display).y > 3000 {
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
            UIView.animate(withDuration: 0.6) {
                self.view.frame = self.disappearingFrame
            } completion: { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // TODO: - Remove
    @objc func showInformation() {
//        player.pause()
//        informationView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: bottomViewHeight)
//        flashView.frame = CGRect(x: 0, y: 0 - view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
//        flashView.alpha = 0
//        display.addSubview(flashView)
//        display.addSubview(informationView)
//        informationView.setProfileImage(from: creatorID)
//        informationView.setUsername(from: creatorID)
//        informationView.flashview = flashView
//        informationView.delegate = self
//        let showFrame = CGRect(x: 0, y: Constants.screenSize.height - bottomViewHeight - view.safeAreaInsets.top, width: view.frame.width, height: bottomViewHeight)
//        UIView.animate(withDuration: 0.4) {
//            self.flashView.alpha = 0.4
//            self.informationView.frame = showFrame
//            self.flashView.isUserInteractionEnabled = true
//        }
    }
}

extension ViewClipViewController: ClipMoreDelegate {
    func userProfileTapped() {
        print("user tapped")
    }
    
    
    func tableViewTapped(at position: Int) {
//        switch position {
//        case 0:
//            UserIDToUser.transform(userID: creatorID) { [weak self] user in
//                guard let self = self else {return}
//                self.coordinator?.showClipCreator(with: user)
//            }
//        case 1:
//            break
//        default:
//            break
//        }
    }
}
