//
//  ViewClipViewController.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/02/2026.
//

import UIKit
import AVKit
import AVFoundation
import Combine
import SwiftUI

final class ViewClipViewController: UIViewController {
    
    // MARK: - Properties
    
    private var overlayHostingController: UIHostingController<ClipOverlayView>?
    
    var clipModel: MyDayClipModel?
    var thumbnail: UIImage?
    var viewModel: ViewClipViewModel?
    
    let display = ViewClipDisplayView()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    
    private var hasSentPublicView = false
    private var hasSentFullView = false
    private var threeSecondTimer: Timer?
    private var videoDuration: Double = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Analytics tracking
    private var watchedMoreThanThreeSeconds = false
    private var watchedFullVideo = false
    private var loopCount = 0
    private var sessionStartTime: Date?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = display
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupThumbnail()
        setupVM()
        setupSwiftUIOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        print("📐 Layout updated - playerLayer frame: \(playerLayer?.frame ?? .zero)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        fireCloseAnalytics()
    }
    
    // MARK: - Setup
    
    private func setupSwiftUIOverlay() {
        let overlayView = ClipOverlayView(
            onClose: { [weak self] in
                self?.backTapped()
            },
            onTogglePlayPause: { [weak self] in
                self?.videoTapped()
            }
        )
        
        let hostingController = UIHostingController(rootView: overlayView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        overlayHostingController = hostingController
    }
    
    private func setupActions() {
        // Tap gesture for play/pause
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        display.videoContainerView.addGestureRecognizer(tapGesture)
    }
    
    private func setupThumbnail() {
        display.thumbnailImageView.image = thumbnail
    }
    
    private func setupPlayer(_ urlString: String) {
        guard let videoURL = URL(string: urlString) else {
            print("❌ Invalid video URL: \(urlString)")
            return
        }

        print("✅ Setting up player with URL: \(urlString)")

        // Setup video player
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = view.bounds

        if let playerLayer = playerLayer {
            display.videoContainerView.layer.insertSublayer(playerLayer, at: 0)
            print("✅ Player layer added to view")
        }

        // Observer for when video ends - loop it
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        // Add progress observer
        setupProgressObserver()
        
        // Wait for player to be ready, then auto-play
        // Start playing as soon as ready
         player?.currentItem?.publisher(for: \.status)
             .sink { [weak self] status in
                 print("📺 Player status: \(status.rawValue)")
                 if status == .readyToPlay {
                     print("✅ Player ready - attempting to play")
                     if let duration = self?.player?.currentItem?.duration.seconds,
                        duration.isFinite {
                         print("📏 Final duration: \(duration)")
                         self?.videoDuration = duration
                     }
                     self?.player?.play()
                 } else if status == .failed {
                     print("❌ Player failed to load")
                     if let error = self?.player?.currentItem?.error {
                         print("Error: \(error.localizedDescription)")
                         print(String(describing: error))
                     }
                 }
             }
             .store(in: &cancellables)
         
         // Wait for actual playback to start before hiding loading
         player?.publisher(for: \.timeControlStatus)
             .sink { [weak self] timeControlStatus in
                 print("⏯️ Time control status: \(timeControlStatus.rawValue)")
                 switch timeControlStatus {
                 case .playing:
                     print("✅ Video is actually playing now")
                     self?.autoPlayVideo()
                 case .paused:
                     print("⏸️ Video paused")
                 case .waitingToPlayAtSpecifiedRate:
                     print("⏳ Waiting for playback...")
                 @unknown default:
                     break
                 }
             }
             .store(in: &cancellables)
    }
    
    private func setupProgressObserver() {
        guard let player = player else { return }
        
        // Update progress every 0.1 seconds
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = player.currentItem?.duration.seconds,
                  duration.isFinite else {
                return
            }
            
            let currentTime = time.seconds
            let progress = Float(currentTime / duration)
            self.display.progressBar.setProgress(progress, animated: true)
        }
    }
    
    private func autoPlayVideo() {
        // Hide thumbnail and loading
        display.thumbnailImageView.isHidden = true
        display.loadingIndicator.stopAnimating()
        display.loadingIndicator.isHidden = true
        display.thumbnailImageView.isHidden = true
        display.loadingIndicator.isHidden = true
        
        // Show progress bar
        display.progressBar.isHidden = false
        
        // Hide pause overlay initially
        display.pauseOverlay.isHidden = true
        
        startPublicViewTimer()
    }
    
    private func setupVM() {
        
        viewModel?.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.display.loadingIndicator.startAnimating()
                    self?.display.loadingIndicator.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel?.$clip
            .receive(on: RunLoop.main)
            .sink { [weak self] clip in
                if let clip {
                    self?.setupPlayer(clip.videoURL)
                }
            }
            .store(in: &cancellables)
        
        viewModel?.loadClip()
    }
    
    private func startPublicViewTimer() {
        guard !hasSentPublicView else { return }

        // If shorter than 3 seconds → count immediately
        if videoDuration < 3 {
            sendPublicView()
            print("less than 3 \(videoDuration)")
            return
        }

        threeSecondTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.sendPublicView()
        }
    }

    // MARK: - Analytics

    /// Captures the current playback position as a 0–1 fraction, then calls the cloud function.
    private func fireCloseAnalytics() {
        let currentTime = player?.currentTime().seconds ?? 0
        let closePosition: Double

        if videoDuration > 0, currentTime.isFinite {
            closePosition = min(currentTime / videoDuration, 1.0)
        } else {
            closePosition = 0
        }

        viewModel?.sendWatchAnalytics(
            watchedMoreThanThreeSeconds: watchedMoreThanThreeSeconds,
            watchedFullVideo: watchedFullVideo,
            closePosition: closePosition,
            loopCount: loopCount
        )
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        player?.pause()
        viewModel?.dismissAction?()
    }
    
    @objc private func videoTapped() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            // Pause
            player.pause()
            display.pauseOverlay.isHidden = false
        } else {
            // Play
            player.play()
            display.pauseOverlay.isHidden = true
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        watchedFullVideo = true
        loopCount += 1

        if !hasSentFullView { sendFullView() }
        // Loop the video - jump progress to zero immediately
        display.progressBar.setProgress(0, animated: false)
        player?.seek(to: .zero) { [weak self] finished in
            if finished {
                self?.player?.play()
            }
        }
    }
    
    func sendPublicView() {
        print("Public Video View")
        watchedMoreThanThreeSeconds = true
        hasSentPublicView = true
    }

    func sendFullView() {
        print("Full Video View")
        hasSentFullView = true
    }
    
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        player?.pause()
        player = nil
    }
}
