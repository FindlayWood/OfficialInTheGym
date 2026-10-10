//
//  ReplayJumpMeasureViewController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import AVFoundation
import AVKit
import UIKit

/// Plays the recorded jump back frame by frame so the athlete can tag take-off
/// and landing, then hands the height on through `onHeightCalculated`. Moved
/// from the app target as it was, with the legacy `JumpCoordinatorFlow`
/// replaced by that closure. Closing it deletes the recording.
class ReplayJumpMeasureViewController: UIViewController {

    // MARK: - Properties
    var onHeightCalculated: ((Double) -> Void)?
    var player: AVPlayer!
    var viewModel = JumpMeasureViewModel()
    var display = ReplayJumpMeasureView()

    // MARK: - View
    override func loadView() {
        view = display
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonActions()
        initViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        player = AVPlayer(url: viewModel.fileURL)
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(layer, at: 0)
    }

    // MARK: - Targets
    func addButtonActions() {
        display.backButton.addTarget(self, action: #selector(removeFromFileManager), for: .touchUpInside)
        display.forwardFrameButton.addTarget(self, action: #selector(forwardFrame), for: .touchUpInside)
        display.backwardFrameButton.addTarget(self, action: #selector(backwardFrame), for: .touchUpInside)
        display.selectedTakeOffFrameButton.addTarget(self, action: #selector(selectTakeOffFrame), for: .touchUpInside)
        display.selectLandingFrameButton.addTarget(self, action: #selector(selectLandingFrame), for: .touchUpInside)
        display.calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        display.slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }

    // MARK: - View Model
    func initViewModel() {
        viewModel.timeValidationCallback = { [weak self] valid in
            self?.display.calculateButton.isHidden = !valid
        }
        viewModel.heightCalculatedCallback = { [weak self] height in
            self?.onHeightCalculated?(height)
        }
    }

    // MARK: - Actions
    @objc func removeFromFileManager() {
        try? FileManager.default.removeItem(at: viewModel.fileURL)
        dismiss(animated: true, completion: nil)
    }

    @objc func forwardFrame() {
        if player.currentItem?.canStepForward ?? false {
            player.currentItem?.step(byCount: 1)
            moveSlider()
        }
    }

    @objc func backwardFrame() {
        if player.currentItem?.canStepBackward ?? false {
            player.currentItem?.step(byCount: -1)
            moveSlider()
        }
    }

    func moveSlider() {
        guard let playerItem = player.currentItem else { return }
        let duration = playerItem.asset.duration.seconds
        let currentTime = Double(playerItem.currentTime().value)
        let timeScale = Double(playerItem.currentTime().timescale)
        let ratio = Float((currentTime / timeScale) / duration)
        display.slider.setValue(ratio, animated: true)
    }

    @objc func selectTakeOffFrame() {
        guard let playerItem = player.currentItem else { return }
        let time = Double(playerItem.currentTime().value) / Double(playerItem.currentTime().timescale)
        viewModel.updateTakeOffTime(with: time)
        if time > 0 && (time < viewModel.landingTime || viewModel.landingTime == 0) {
            display.selectedTakeOff()
            display.addTakeOffImage()
        }
    }

    @objc func selectLandingFrame() {
        guard let playerItem = player.currentItem else { return }
        let time = Double(playerItem.currentTime().value) / Double(playerItem.currentTime().timescale)
        viewModel.updateLandingTime(with: time)
        if time > 0 && (time > viewModel.takeOffTime || viewModel.takeOffTime == 0) {
            display.selectedLanding()
            display.addLandingImage()
        }
    }

    @objc func calculateTapped() {
        viewModel.calculate()
    }

    @objc func handleSliderChange() {
        guard let playerItem = player.currentItem else { return }
        let videoLength = playerItem.asset.duration.seconds
        let timeToSeek = videoLength * Double(display.slider.value)
        let time = CMTime(seconds: timeToSeek, preferredTimescale: playerItem.asset.duration.timescale)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
