//
//  ReplayJumpMeasureViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SCLAlertView


class ReplayJumpMeasureViewController: UIViewController {
    var player: AVPlayer!
    var viewModel = JumpMeasureViewModel()
    
    var display = ReplayJumpMeasureView()
    
    var frames: [UIImage] = [UIImage]()
    var timeStamps: [Double] = [Double]()
    var currentFrame: Int = 0

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
    // MARK: - Action
    @objc func removeFromFileManager() {
        try? FileManager.default.removeItem(at: viewModel.fileURL)
        dismiss(animated: true, completion: nil)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.timeValidationCallback = { [weak self] (valid) in
            guard let self = self else {return}
            if valid {
                self.display.calculateButton.isHidden = false
            } else {
                self.display.calculateButton.isHidden = true
            }
        }
        viewModel.heightCalculatedCallback = { [weak self] (height) in
            guard let self = self else {return}
            let vc = JumpResultsViewController()
            vc.viewModel.jumpResultCM = height
            vc.viewModel.currentValue = height
            self.present(vc, animated: true)
//            self.showHeight(height: height)
        }
    }
    // MARK: - Frame by Frame
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
        guard let playerItem = player.currentItem else {return}
        let duration = playerItem.asset.duration.seconds
        let currentTime = Double(playerItem.currentTime().value)
        let timeScale = Double(playerItem.currentTime().timescale)
        let ratio = Float((currentTime/timeScale) / duration)
        display.slider.setValue(ratio, animated: true)
    }
    // MARK: - Selecting Frames
    @objc func selectTakeOffFrame() {
        guard let playerItem = player.currentItem else {return}
        let currentTime = Double(playerItem.currentTime().value)
        let timeScale = Double(playerItem.currentTime().timescale)
        let time = currentTime / timeScale
        viewModel.updateTakeOffTime(with: time)
        if time > 0 && (time < viewModel.landingTime || viewModel.landingTime == 0) {
            display.selectedTakeOff()
            display.addTakeOffImage()
        }
    }
    @objc func selectLandingFrame() {
        guard let playerItem = player.currentItem else {return}
        let currentTime = Double(playerItem.currentTime().value)
        let timeScale = Double(playerItem.currentTime().timescale)
        let time = currentTime / timeScale
        viewModel.updateLandingTime(with: time)
        if time > 0 && (time > viewModel.takeOffTime || viewModel.takeOffTime == 0) {
            display.selectedLanding()
            display.addLandingImage()
        }
    }
    // MARK: - Actions
    @objc func calculateTapped() {
        viewModel.calculate()
    }
    func showHeight(height: Double) {
        let alert = SCLAlertView()
        alert.showInfo("Jump Height", subTitle: "You jumped \(height)cm!", closeButtonTitle: "ok")
    }
    @objc func handleSliderChange() {
        guard let playerItem = player.currentItem else {return}
        let videoLength = playerItem.asset.duration.seconds
        let timeToSeek = videoLength * Double(display.slider.value)
        let time = CMTime(seconds: timeToSeek, preferredTimescale: playerItem.asset.duration.timescale)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
