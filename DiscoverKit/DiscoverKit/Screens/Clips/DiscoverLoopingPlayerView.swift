//
//  DiscoverLoopingPlayerView.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import AVFoundation
import SwiftUI
import UIKit

/// A clip playing on a loop, reporting how far through it is and how many
/// times it has looped — the two things a watch is recorded from.
///
/// DiscoverKit's own, not MyDayKit's `LoopingVideoPlayer`: frameworks do not
/// import each other, and this one also reports loops, which MyDay's does not.
struct DiscoverLoopingPlayerView: UIViewRepresentable {
    let url: URL
    let onProgress: (Double) -> Void
    let onLoop: (Int) -> Void

    func makeUIView(context: Context) -> DiscoverLoopingPlayerUIView {
        let view = DiscoverLoopingPlayerUIView(url: url)
        view.onProgress = onProgress
        view.onLoop = onLoop
        view.play()
        return view
    }

    func updateUIView(_ uiView: DiscoverLoopingPlayerUIView, context: Context) {}

    static func dismantleUIView(_ uiView: DiscoverLoopingPlayerUIView, coordinator: ()) {
        uiView.stop()
    }
}

final class DiscoverLoopingPlayerUIView: UIView {

    var onProgress: ((Double) -> Void)?
    var onLoop: ((Int) -> Void)?

    private let playerLayer = AVPlayerLayer()
    private let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var timeObserver: Any?
    private var loopObservation: NSKeyValueObservation?

    init(url: URL) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        self.looper = looper
        loopObservation = looper.observe(\.loopCount, options: [.new]) { [weak self] looper, _ in
            let count = looper.loopCount
            DispatchQueue.main.async { self?.onLoop?(count) }
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let duration = self?.player.currentItem?.duration.seconds,
                  duration.isFinite, duration > 0 else { return }
            self?.onProgress?(min(max(time.seconds / duration, 0), 1))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func play() {
        player.play()
    }

    func stop() {
        player.pause()
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        loopObservation = nil
        looper?.disableLooping()
    }
}
