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

enum clipViewingState {
    case fullScreen
    case dismissed
}

class ViewClipViewController: UIViewController {
    
    weak var coordinator: ViewClipFlow?
    
    var player: AVPlayer!
    
    var storageURL: String!
    
    var display = ViewClipView()
    
    var informationView = ViewClipBottomView()
    
    var flashView = FlashView()
    
    private var bottomViewHeight = Constants.screenSize.height * 0.2
    
    var paused: Bool = false
    
    var exerciseName: String!
    
    var creatorID: String!
    
    var workoutID: String!
    
    private lazy var originalFrame = view.bounds
    private lazy var disappearingFrame = CGRect(x: 0, y: Constants.screenSize.height, width: Constants.screenSize.width, height: view.frame.height)
    private lazy var originPoint = originalFrame.origin

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        showLoading()
        addObservers()
        addButtonActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startVideo()
        
        guard let currentVideoLength = ((player.currentItem?.asset) as? AVURLAsset)?.duration.seconds else {return}
        let currentTime = player.currentTime()
        print(currentTime)
        print(currentVideoLength)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        display.exerciseName.text = exerciseName
        view.addSubview(display)
    }
    
    func addButtonActions() {
        display.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        display.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        display.addGestureRecognizer(pan)
        display.moreButton.addTarget(self, action: #selector(showInformation), for: .touchUpInside)
    }
 
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(clipFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func showLoading() {
        display.loadingIndicator.startAnimating()
    }
    
    func startVideo() {
        guard let playerURL = URL(string: storageURL) else {return}
        player = AVPlayer(url: playerURL)
        
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        display.removeLoadingIndicator()
        player.play()
        addTimerObserver()
    }
    
    @objc func clipFinished() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func togglePause() {
        if paused {
            player.play()
            paused.toggle()
        } else {
            player.pause()
            paused.toggle()
        }
    }
    @objc func back() {
        player.pause()
        self.dismiss(animated: true, completion: nil)
    }


    func addTimerObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else {return}
            if self.player.currentItem?.status == .readyToPlay {
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                
                let seconds = Double(currentTime)
                guard let currentVideoLength = ((self.player.currentItem?.asset) as? AVURLAsset)?.duration.seconds else {return}
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

    @objc func showInformation() {
        player.pause()
        informationView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: bottomViewHeight)
        flashView.frame = CGRect(x: 0, y: 0 - view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
        flashView.alpha = 0
        display.addSubview(flashView)
        display.addSubview(informationView)
        informationView.setProfileImage(from: creatorID)
        informationView.setUsername(from: creatorID)
        informationView.flashview = flashView
        informationView.delegate = self
        let showFrame = CGRect(x: 0, y: Constants.screenSize.height - bottomViewHeight - view.safeAreaInsets.top, width: view.frame.width, height: bottomViewHeight)
        UIView.animate(withDuration: 0.4) {
            self.flashView.alpha = 0.4
            self.informationView.frame = showFrame
            self.flashView.isUserInteractionEnabled = true
        }
    }
}

extension ViewClipViewController: ClipMoreDelegate {
    func userProfileTapped() {
        print("user tapped")
    }
    
    
    func tableViewTapped(at position: Int) {
        switch position {
        case 0:
            UserIDToUser.transform(userID: creatorID) { [weak self] user in
                guard let self = self else {return}
                self.coordinator?.showClipCreator(with: user)
            }
        case 1:
            break
        default:
            break
        }
    }
}
