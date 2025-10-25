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
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(url: url)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(url: URL) {
        super.init(frame: .zero)
        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill   // 👈 Fill the screen
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
