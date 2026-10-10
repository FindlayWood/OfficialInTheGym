//
//  ReplayJumpMeasureViewController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import AVFoundation
import AVKit
import UIKit

/// Plays a recorded jump back frame by frame so the athlete can tag each event
/// in the test's tag plan, then hands the measured attempt on through
/// `onMeasured`. Closing it deletes the recording.
///
/// The arithmetic is `JumpTaggingViewModel` / `JumpTiming` / `JumpPhysics`;
/// this only reads the player's current time and draws.
class ReplayJumpMeasureViewController: UIViewController {

    // MARK: - Properties
    var onMeasured: ((JumpAttempt) -> Void)?
    var fileURL: URL!
    var tagging: JumpTaggingViewModel
    private let kind: JumpTestKind
    private var player: AVPlayer!
    private let display = ReplayJumpMeasureView()

    // MARK: - Initializer
    init(kind: JumpTestKind) {
        self.tagging = JumpTaggingViewModel(kind: kind)
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View
    override func loadView() {
        view = display
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonActions()
        player = AVPlayer(url: fileURL)
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(layer, at: 0)
        refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.first { $0 is AVPlayerLayer }?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Targets
    private func addButtonActions() {
        display.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        display.undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        display.doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        display.forwardFrameButton.addTarget(self, action: #selector(forwardFrame), for: .touchUpInside)
        display.backwardFrameButton.addTarget(self, action: #selector(backwardFrame), for: .touchUpInside)
        display.tagButton.addTarget(self, action: #selector(tagCurrentFrame), for: .touchUpInside)
        display.slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }

    private func refresh(message: String? = nil) {
        display.show(prompt: tagging.prompt, canUndo: !tagging.times.isEmpty)
        if let message {
            display.show(message: message)
        } else if let attempt = tagging.attempt {
            display.show(message: "\(kind.headlineText(of: attempt)). Tap ✓ to keep it.")
        } else {
            display.show(message: tagging.hint)
        }
    }

    private var currentTime: Double {
        player.currentItem?.currentTime().seconds ?? 0
    }

    // MARK: - Actions
    @objc private func tagCurrentFrame() {
        guard let event = tagging.nextEvent else { return }
        switch tagging.tag(at: currentTime) {
        case .accepted:
            display.addMarker(for: event)
            refresh()
        case .rejected(let reason):
            refresh(message: reason)
        }
    }

    @objc private func undo() {
        tagging.undo()
        display.removeLastMarker()
        refresh()
    }

    @objc private func done() {
        guard let attempt = tagging.attempt else { return }
        onMeasured?(attempt)
    }

    @objc private func close() {
        try? FileManager.default.removeItem(at: fileURL)
        dismiss(animated: true)
    }

    @objc private func forwardFrame() {
        if player.currentItem?.canStepForward ?? false {
            player.currentItem?.step(byCount: 1)
            moveSlider()
        }
    }

    @objc private func backwardFrame() {
        if player.currentItem?.canStepBackward ?? false {
            player.currentItem?.step(byCount: -1)
            moveSlider()
        }
    }

    private func moveSlider() {
        guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
        display.slider.setValue(Float(currentTime / duration), animated: true)
    }

    @objc private func handleSliderChange() {
        guard let item = player.currentItem else { return }
        let duration = item.duration.seconds
        guard duration > 0 else { return }
        let time = CMTime(seconds: duration * Double(display.slider.value), preferredTimescale: item.duration.timescale)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
