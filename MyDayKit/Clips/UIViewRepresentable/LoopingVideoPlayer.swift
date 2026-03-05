//
//  LoopingVideoPlayer.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import AVKit
import SwiftUI

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(url: url)
        view.onProgressUpdate = { newProgress in
            DispatchQueue.main.async {
                progress = newProgress
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if isPlaying {
            uiView.play()
        } else {
            uiView.pause()
        }
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    private var timeObserver: Any?
    
    var onProgressUpdate: ((Double) -> ())?
    
    init(url: URL) {
        super.init(frame: .zero)
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        self.player = queuePlayer
        
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // Add time observer for progress
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = queuePlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration.seconds,
                  duration.isFinite else { return }
            let progress = time.seconds / duration
            self.onProgressUpdate?(progress)
        }
        
        queuePlayer.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
}
