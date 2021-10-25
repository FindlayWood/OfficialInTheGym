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
    
    var viewModel = JumpMeasureViewModel()
    
    var display = ReplayJumpMeasureView()
    
    var frames: [UIImage] = [UIImage]()
    var timeStamps: [Double] = [Double]()
    var currentFrame: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonActions()
        initViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        display.imageView.image = frames[currentFrame]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(display)
    }
    
    func addButtonActions() {
        display.backButton.addTarget(self, action: #selector(removeFromFileManager), for: .touchUpInside)
        display.forwardFrameButton.addTarget(self, action: #selector(forwardFrame), for: .touchUpInside)
        display.backwardFrameButton.addTarget(self, action: #selector(backwardFrame), for: .touchUpInside)
        display.selectedTakeOffFrameButton.addTarget(self, action: #selector(selectTakeOffFrame), for: .touchUpInside)
        display.selectLandingFrameButton.addTarget(self, action: #selector(selectLandingFrame), for: .touchUpInside)
        display.calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        display.slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }
 


    
    @objc func removeFromFileManager() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Init View Model
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
            self.showHeight(height: height)
        }
    }
    
    // MARK: - Frame by Frame
    @objc func forwardFrame() {
        if currentFrame < frames.count - 1 {
            currentFrame += 1
            display.imageView.image = frames[currentFrame]
            let updatedValue = Float(currentFrame) / Float(frames.count)
            display.slider.setValue(updatedValue, animated: true)
        }
    }
    @objc func backwardFrame() {
        if currentFrame > 0 {
            currentFrame -= 1
            display.imageView.image = frames[currentFrame]
            let updatedValue = Float(currentFrame) / Float(frames.count)
            display.slider.setValue(updatedValue, animated: true)
        }
    }
    
    // MARK: - Selecting Frames
    @objc func selectTakeOffFrame() {
        print(timeStamps[currentFrame])
        viewModel.updateTakeOffTime(with: timeStamps[currentFrame])
        
    }
    @objc func selectLandingFrame() {
        print(timeStamps[currentFrame])
        viewModel.updateLandingTime(with: timeStamps[currentFrame])
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
        let value = display.slider.value
        let newSliderValue = Int(value * Float(frames.count - 1))
        currentFrame = newSliderValue
        display.imageView.image = frames[currentFrame]
        let updatedValue = Float(currentFrame) / Float(frames.count)
        display.slider.setValue(updatedValue, animated: true)
    }
}
